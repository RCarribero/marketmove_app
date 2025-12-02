import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/services/profile_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _profileService = ProfileService(Supabase.instance.client);
  List<Profile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final profiles = await _profileService.getAllProfiles();
      setState(() {
        _profiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando usuarios: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Usuarios')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(profile.email?[0].toUpperCase() ?? '?'),
                  ),
                  title: Text(profile.email ?? 'Sin Email'),
                  subtitle: Text('Rol: ${profile.role}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar a gastos pasando el userId como query param o extra
                    context.push('/gastos?userId=${profile.id}');
                  },
                );
              },
            ),
    );
  }
}
