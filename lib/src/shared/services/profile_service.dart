import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileService {
  final SupabaseClient _client;

  ProfileService(this._client);

  /// Obtiene el perfil del usuario actual.
  Future<Profile?> getCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(response);
    } catch (e) {
      // Si no existe perfil (ej. error en trigger), retornamos null o un default
      return null;
    }
  }

  /// Obtiene todos los perfiles (Solo para Admins).
  Future<List<Profile>> getAllProfiles() async {
    final response = await _client
        .from('profiles')
        .select()
        .order('created_at');
    return (response as List).map((e) => Profile.fromJson(e)).toList();
  }
}
