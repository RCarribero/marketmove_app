import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _parseError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('User already registered')) {
      return 'Este correo ya está registrado';
    }
    if (errorString.contains('Invalid email')) {
      return 'Correo electrónico inválido';
    }
    if (errorString.contains('Weak password')) {
      return 'La contraseña es muy débil';
    }

    return 'Error al crear cuenta. Intenta nuevamente';
  }

  Future<void> _register() async {
    setState(() => _error = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validaciones
    if (email.isEmpty) {
      setState(() => _error = 'Por favor ingresa tu correo electrónico');
      return;
    }

    if (!email.contains('@')) {
      setState(() => _error = 'Correo electrónico inválido');
      return;
    }

    if (password.isEmpty) {
      setState(() => _error = 'Por favor ingresa una contraseña');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    try {
      print(
        '🔍 DEBUG Register - Email: "$email", Password length: ${password.length}',
      );

      await context.read<AuthProvider>().signUp(email, password);

      if (mounted) {
        // Show custom toast notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  '✓ Cuenta creada exitosamente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.85),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );

        // Wait a bit before navigating
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to login with email
        if (mounted) {
          context.go('/login?email=$email');
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
              AppColors.primary.withOpacity(0.8),
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
                  // Logo
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Únete a MarketMove',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Register Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2),
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
                                hintText: 'Mínimo 6 caracteres',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),

                            // Confirm Password Field
                            TextField(
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Confirmar Contraseña',
                                hintText: 'Repite tu contraseña',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                            ),

                            // Error Message
                            if (_error != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(0.3),
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

                            // Register Button
                            if (isLoading)
                              const Center(child: CircularProgressIndicator())
                            else ...[
                              ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
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
                              const SizedBox(height: 16),

                              // Back to Login Button
                              TextButton(
                                onPressed: () => context.go('/'),
                                child: const Text(
                                  '¿Ya tienes cuenta? Inicia sesión',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
