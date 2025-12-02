import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client;
  final ProfileService _profileService;

  AuthProvider(this._client, this._profileService);

  User? _user;
  Profile? _profile;
  bool _isLoading = false;

  User? get user => _user;
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isAdmin => _profile?.role == 'admin';

  /// Carga la sesión actual y el perfil del usuario.
  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();

    final session = _client.auth.currentSession;
    _user = session?.user;

    if (_user != null) {
      _profile = await _profileService.getCurrentProfile();
    } else {
      _profile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;
      if (_user != null) {
        _profile = await _profileService.getCurrentProfile();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      _user = response.user;
      // El perfil se crea via trigger, así que esperamos un poco o lo cargamos luego
      if (_user != null) {
        // Pequeña espera para dar tiempo al trigger
        await Future.delayed(const Duration(seconds: 1));
        _profile = await _profileService.getCurrentProfile();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'io.supabase.flutterquickstart://login-callback', // Default or custom scheme
      );
      // Note: The actual sign-in completion happens via deep link callback
      // which Supabase SDK handles if configured correctly.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _user = null;
    _profile = null;
    notifyListeners();
  }
}
