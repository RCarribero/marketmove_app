import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../data/embedded_mock_data.dart';

class ProfileService {
  final SupabaseClient? _client;

  ProfileService([this._client]);

  /// Obtiene el perfil del usuario actual (con fallback embebido).
  Future<Profile?> getCurrentProfile([String? email]) async {
    final clientEmail = _client?.auth.currentUser?.email ?? email;
    if (_client != null) {
      try {
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          final response = await _client
              .from('profiles')
              .select()
              .eq('id', userId)
              .single();
          return Profile.fromJson(response);
        }
      } catch (_) {
        // Fallback
      }
    }
    if (clientEmail != null && !clientEmail.toLowerCase().contains('admin')) {
      return EmbeddedMockData.demoClientProfile;
    }
    return EmbeddedMockData.demoProfile;
  }

  /// Obtiene todos los perfiles (Solo para Admins).
  Future<List<Profile>> getAllProfiles() async {
    if (_client != null) {
      try {
        final response = await _client
            .from('profiles')
            .select()
            .order('created_at');
        final list = (response as List).map((e) => Profile.fromJson(e)).toList();
        if (list.isNotEmpty) return list;
      } catch (_) {
        // Fallback
      }
    }
    return [
      EmbeddedMockData.demoProfile,
      EmbeddedMockData.demoClientProfile,
    ];
  }
}
