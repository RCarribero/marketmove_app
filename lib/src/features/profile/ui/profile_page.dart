import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/services/interactive_tutorial_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profile = authProvider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con foto de perfil
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          backgroundImage:
                              user?.userMetadata?['avatar_url'] != null
                              ? NetworkImage(user!.userMetadata!['avatar_url'])
                              : null,
                          child: user?.userMetadata?['avatar_url'] == null
                              ? Text(
                                  (user?.email ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Nombre
                      Text(
                        user?.userMetadata?['full_name'] ??
                            user?.email?.split('@')[0] ??
                            'Usuario',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Email
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Mi Perfil'),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seccion: Informacion de Cuenta
                  _buildSectionTitle('Informacion de Cuenta'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    isDark: isDark,
                    children: [
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? 'No definido',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'Nombre',
                        value:
                            user?.userMetadata?['full_name'] ?? 'No definido',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Rol',
                        value: profile?.role == 'admin'
                            ? 'Administrador'
                            : 'Usuario',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Miembro desde',
                        value: _formatDate(user?.createdAt),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Seccion: Seguridad
                  _buildSectionTitle('Seguridad'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    isDark: isDark,
                    children: [
                      _buildActionTile(
                        icon: Icons.lock_outline,
                        iconColor: AppColors.warning,
                        title: 'Cambiar Contraseña',
                        subtitle: 'Actualiza tu contraseña de acceso',
                        onTap: () => _showChangePasswordDialog(),
                      ),
                      const Divider(height: 8),
                      _buildActionTile(
                        icon: Icons.email_outlined,
                        iconColor: AppColors.info,
                        title: 'Cambiar Email',
                        subtitle: 'Actualiza tu correo electronico',
                        onTap: () => _showChangeEmailDialog(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Seccion: Cuentas Vinculadas
                  _buildSectionTitle('Cuentas Vinculadas'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    isDark: isDark,
                    children: [
                      _buildIdentityTile(
                        provider: 'google',
                        providerName: 'Google',
                        icon: Icons.g_mobiledata,
                        color: Colors.red,
                        identities: authProvider.getLinkedIdentities(),
                      ),
                      const Divider(height: 8),
                      _buildIdentityTile(
                        provider: 'github',
                        providerName: 'GitHub',
                        icon: Icons.code,
                        color: Colors.black87,
                        identities: authProvider.getLinkedIdentities(),
                      ),
                      const Divider(height: 8),
                      _buildIdentityTile(
                        provider: 'apple',
                        providerName: 'Apple',
                        icon: Icons.apple,
                        color: Colors.black,
                        identities: authProvider.getLinkedIdentities(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Seccion: Sesion
                  _buildSectionTitle('Sesion'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    isDark: isDark,
                    children: [
                      _buildActionTile(
                        icon: Icons.refresh,
                        iconColor: AppColors.info,
                        title: 'Actualizar Datos',
                        subtitle: 'Recargar informacion del perfil',
                        onTap: () async {
                          await authProvider.refreshUser();
                          if (mounted) {
                            ToastService.success(context, 'Datos actualizados');
                          }
                        },
                      ),
                      const Divider(height: 8),
                      _buildActionTile(
                        icon: Icons.school_outlined,
                        iconColor: AppColors.primary,
                        title: 'Ver Tutorial',
                        subtitle: 'Aprende a usar la aplicacion',
                        onTap: () async {
                          await InteractiveTutorialService.resetTutorial();
                          if (mounted) {
                            Navigator.of(context).pop();
                            ToastService.info(
                              context,
                              'Vuelve al Dashboard para ver el tutorial',
                            );
                          }
                        },
                      ),
                      const Divider(height: 8),
                      _buildActionTile(
                        icon: Icons.logout,
                        iconColor: AppColors.error,
                        title: 'Cerrar Sesion',
                        subtitle: 'Salir de tu cuenta',
                        onTap: () => _showLogoutDialog(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildInfoCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityTile({
    required String provider,
    required String providerName,
    required IconData icon,
    required Color color,
    required List<UserIdentity> identities,
  }) {
    final isLinked = identities.any((i) => i.provider == provider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  providerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isLinked ? 'Vinculada' : 'No vinculada',
                  style: TextStyle(
                    fontSize: 12,
                    color: isLinked ? AppColors.success : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isLinked)
            TextButton(
              onPressed: () => _unlinkIdentity(provider, identities),
              child: const Text('Desvincular'),
            )
          else
            ElevatedButton(
              onPressed: () => _linkIdentity(provider),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('Vincular'),
            ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'No disponible';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'No disponible';
    }
  }

  void _showChangePasswordDialog() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    String? error;

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
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_outline, color: AppColors.warning),
              ),
              const SizedBox(width: 12),
              const Text('Cambiar Contraseña'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (newPasswordController.text.length < 6) {
                        setDialogState(
                          () => error =
                              'La contraseña debe tener al menos 6 caracteres',
                        );
                        return;
                      }
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        setDialogState(
                          () => error = 'Las contraseñas no coinciden',
                        );
                        return;
                      }

                      setDialogState(() {
                        isLoading = true;
                        error = null;
                      });

                      try {
                        await context.read<AuthProvider>().updatePassword(
                          newPasswordController.text,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          ToastService.success(
                            context,
                            'Contraseña actualizada correctamente',
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          error = 'Error al cambiar la contraseña';
                          isLoading = false;
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController();
    bool isLoading = false;
    String? error;
    String? success;

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
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.email_outlined, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              const Text('Cambiar Email'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa tu nuevo correo electronico. Recibiras un email de confirmacion.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Nuevo Email',
                  hintText: 'nuevo@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              if (success != null) ...[
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
                          success!,
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
              child: const Text('Cerrar'),
            ),
            if (success == null)
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          setDialogState(
                            () => error = 'Ingresa un email valido',
                          );
                          return;
                        }

                        setDialogState(() {
                          isLoading = true;
                          error = null;
                        });

                        try {
                          await context.read<AuthProvider>().updateEmail(email);
                          setDialogState(() {
                            success =
                                'Se envio un email de confirmacion a $email';
                            isLoading = false;
                          });
                        } catch (e) {
                          setDialogState(() {
                            error = 'Error al actualizar el email';
                            isLoading = false;
                          });
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar'),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text('Cerrar Sesion'),
          ],
        ),
        content: const Text('Estas seguro que deseas cerrar sesion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar Sesion'),
          ),
        ],
      ),
    );
  }

  Future<void> _linkIdentity(String provider) async {
    try {
      OAuthProvider oauthProvider;
      switch (provider) {
        case 'google':
          oauthProvider = OAuthProvider.google;
          break;
        case 'github':
          oauthProvider = OAuthProvider.github;
          break;
        case 'apple':
          oauthProvider = OAuthProvider.apple;
          break;
        default:
          return;
      }

      await context.read<AuthProvider>().linkIdentity(oauthProvider);
      if (mounted) {
        ToastService.success(context, 'Cuenta vinculada correctamente');
      }
    } catch (e) {
      if (mounted) {
        ToastService.error(context, 'Error al vincular la cuenta');
      }
    }
  }

  Future<void> _unlinkIdentity(
    String provider,
    List<UserIdentity> identities,
  ) async {
    final identity = identities.firstWhere(
      (i) => i.provider == provider,
      orElse: () => throw Exception('Identity not found'),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Desvincular Cuenta'),
        content: Text(
          'Estas seguro que deseas desvincular tu cuenta de ${provider.toUpperCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<AuthProvider>().unlinkIdentity(identity);
                if (mounted) {
                  ToastService.success(context, 'Cuenta desvinculada');
                }
              } catch (e) {
                if (mounted) {
                  ToastService.error(context, 'Error al desvincular');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Desvincular'),
          ),
        ],
      ),
    );
  }
}
