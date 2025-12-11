import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill email if coming from registration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final email = uri.queryParameters['email'];
      if (email != null && email.isNotEmpty) {
        _emailController.text = email;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _parseError(dynamic error) {
    final errorString = error.toString();

    // Supabase errors
    if (errorString.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (errorString.contains('Email not confirmed')) {
      return 'Por favor confirma tu correo electrónico';
    }
    if (errorString.contains('User already registered')) {
      return 'Este correo ya está registrado';
    }
    if (errorString.contains('anonymous_provider_disabled')) {
      return 'Error de Supabase: Verifica la configuración de Email Auth';
    }
    if (errorString.contains('statusCode: 422')) {
      return 'Datos inválidos. Verifica tu correo y contraseña';
    }
    if (errorString.contains('Network')) {
      return 'Error de conexión. Verifica tu internet';
    }

    // Generic validation
    if (errorString.contains('email')) {
      return 'Correo electrónico inválido';
    }
    if (errorString.contains('password')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    // Default
    return 'Error inesperado. Intenta nuevamente';
  }

  Future<void> _login() async {
    try {
      await context.read<AuthProvider>().signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // Check if user is admin
        final authProvider = context.read<AuthProvider>();
        if (authProvider.isAdmin) {
          context.go('/home');
        } else {
          context.go('/user-dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _parseError(e);
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    bool isLoading = false;
    String? dialogError;
    String? successMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_reset, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const Text('Recuperar Contraseña'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ingresa tu correo electronico y te enviaremos un enlace para restablecer tu contraseña.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electronico',
                  hintText: 'tu@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              if (dialogError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dialogError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              if (successMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          successMessage!,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            if (successMessage == null)
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          setDialogState(() {
                            dialogError = 'Ingresa un correo valido';
                          });
                          return;
                        }

                        setDialogState(() {
                          isLoading = true;
                          dialogError = null;
                        });

                        try {
                          await context.read<AuthProvider>().resetPassword(
                            email,
                          );
                          setDialogState(() {
                            successMessage =
                                'Se envio un enlace de recuperacion a $email';
                            isLoading = false;
                          });
                        } catch (e) {
                          setDialogState(() {
                            dialogError =
                                'Error al enviar el email. Intenta nuevamente.';
                            isLoading = false;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar Enlace'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>((p) => p.isLoading);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animated container
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'MarketMove',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gestiona tu negocio inteligente',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Correo Electrónico',
                                hintText: 'tu@email.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            TextField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Contraseña',
                                hintText: '••••••••',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _showForgotPasswordDialog(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Olvide mi contraseña',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // Error Message
                            if (_error != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Login Button
                            if (isLoading)
                              const Center(child: CircularProgressIndicator())
                            else ...[
                              ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'INICIAR SESIÓN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Sign Up Button
                              OutlinedButton(
                                onPressed: () => context.go('/register'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'CREAR CUENTA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'O continúa con',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Google Sign In
                              OutlinedButton.icon(
                                onPressed: () {
                                  context
                                      .read<AuthProvider>()
                                      .signInWithGoogle();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.g_mobiledata, size: 20),
                                ),
                                label: const Text(
                                  'Continuar con Google',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    '© 2024 MarketMove. Todos los derechos reservados.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
