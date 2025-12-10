import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const stripeWebhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')!

serve(async (req) => {
    try {
        const body = await req.text()
        const signature = req.headers.get('stripe-signature')

        // Parsear el evento de Stripe
        const event = JSON.parse(body)

        if (event.type === 'checkout.session.completed') {
            const session = event.data.object
            const customerEmail = session.customer_email || session.customer_details?.email

            if (!customerEmail) {
                return new Response(JSON.stringify({ error: 'No email found' }), { status: 400 })
            }

            // Determinar el plan basado en el amount
            const amount = session.amount_total / 100 // Convertir de centavos
            let planId = 'monthly'
            let isAnnual = false

            if (amount === 999) {
                planId = 'lifetime'
                isAnnual = true
            } else if (amount === 299) {
                planId = 'annual'
                isAnnual = true
            }

            // Conectar a Supabase
            const supabase = createClient(supabaseUrl, supabaseServiceKey)

            // Buscar usuario por email
            const { data: users } = await supabase.auth.admin.listUsers()
            const user = users.users.find(u => u.email === customerEmail)

            if (!user) {
                return new Response(JSON.stringify({ error: 'User not found' }), { status: 404 })
            }

            // Calcular fecha de fin
            const now = new Date()
            let endDate
            if (planId === 'lifetime') {
                endDate = new Date(now.getFullYear() + 100, now.getMonth(), now.getDate())
            } else if (isAnnual) {
                endDate = new Date(now.getFullYear() + 1, now.getMonth(), now.getDate())
            } else {
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, now.getDate())
            }

            // Actualizar o crear suscripcion
            const { error } = await supabase
                .from('subscriptions')
                .upsert({
                    user_id: user.id,
                    device_id: `stripe_${session.id}`,
                    status: 'active',
                    plan_id: planId,
                    is_annual: isAnnual,
                    subscription_start: now.toISOString(),
                    subscription_end: endDate.toISOString(),
                    stripe_customer_id: session.customer,
                    updated_at: now.toISOString()
                }, { onConflict: 'user_id' })

            if (error) {
                console.error('Error updating subscription:', error)
                return new Response(JSON.stringify({ error: error.message }), { status: 500 })
            }

            return new Response(JSON.stringify({ success: true, email: customerEmail, plan: planId }), { status: 200 })
        }

        return new Response(JSON.stringify({ received: true }), { status: 200 })
    } catch (err) {
        console.error('Webhook error:', err)
        return new Response(JSON.stringify({ error: err.message }), { status: 400 })
    }
})
