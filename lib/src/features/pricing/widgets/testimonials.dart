import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';

/// Widget de testimonios de clientes
class Testimonials extends StatelessWidget {
  final bool isDark;

  const Testimonials({super.key, required this.isDark});

  static const _testimonials = [
    Testimonial(
      name: 'Maria Garcia',
      role: 'CEO, TechStart',
      content:
          'MarketMove transformo la forma en que gestionamos nuestros clientes. Simple, potente y muy intuitivo.',
      avatar: 'MG',
      rating: 5,
    ),
    Testimonial(
      name: 'Carlos Rodriguez',
      role: 'Director de Ventas, InnovaGroup',
      content:
          'El mejor CRM que hemos usado. El equipo de soporte es excepcional y el ROI fue inmediato.',
      avatar: 'CR',
      rating: 5,
    ),
    Testimonial(
      name: 'Ana Martinez',
      role: 'Fundadora, CreativeHub',
      content:
          'Pase de Excel a MarketMove y no puedo creer que esperara tanto. Es exactamente lo que necesitaba.',
      avatar: 'AM',
      rating: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Lo que dicen nuestros clientes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Miles de empresas confian en nosotros',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                children: _testimonials
                    .map(
                      (t) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _TestimonialCard(
                            testimonial: t,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }
            return Column(
              children: _testimonials
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _TestimonialCard(testimonial: t, isDark: isDark),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final Testimonial testimonial;
  final bool isDark;

  const _TestimonialCard({required this.testimonial, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < testimonial.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Text(
            '"${testimonial.content}"',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Author
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  testimonial.avatar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      testimonial.role,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Testimonial {
  final String name;
  final String role;
  final String content;
  final String avatar;
  final int rating;

  const Testimonial({
    required this.name,
    required this.role,
    required this.content,
    required this.avatar,
    required this.rating,
  });
}
