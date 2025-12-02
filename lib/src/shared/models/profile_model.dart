/// Modelo que representa el perfil de un usuario.
///
/// Corresponde a la tabla 'profiles' en Supabase.
class Profile {
  /// ID del usuario (coincide con auth.users.id).
  final String id;

  /// Email del usuario.
  final String? email;

  /// Rol del usuario ('user' o 'admin').
  final String role;

  /// Fecha de creación.
  final DateTime createdAt;

  const Profile({
    required this.id,
    this.email,
    required this.role,
    required this.createdAt,
  });

  /// Verifica si el usuario es administrador.
  bool get isAdmin => role == 'admin';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
