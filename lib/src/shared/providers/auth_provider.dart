import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../../features/pricing/services/subscription_service.dart';
import '../../features/pricing/models/pricing_plan.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client;
  final ProfileService _profileService;

  AuthProvider(this._client, this._profileService);

  User? _user;
  Profile? _profile;
  UserSubscription? _subscription;
  bool _isLoading = false;

  User? get user => _user;
  Profile? get profile => _profile;
  UserSubscription? get subscription => _subscription;
  bool get isLoading => _isLoading;
  bool get isAdmin => _profile?.role == 'admin';

  // Getters de suscripcion
  bool get hasActiveSubscription =>
      _subscription?.hasActiveSubscription ?? false;
  bool get isTrialActive => _subscription?.isTrialActive ?? false;
  int get trialDaysRemaining => _subscription?.trialDaysRemaining ?? 0;
  String get currentPlanId => _subscription?.planId ?? 'free';

  /// Carga la sesión actual y el perfil del usuario.
  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();

    final session = _client.auth.currentSession;
    _user = session?.user;

    if (_user != null) {
      _profile = await _profileService.getCurrentProfile();
      // Cargar suscripcion
      _subscription = await SubscriptionService.getSubscription();
      await SubscriptionService.checkAndUpdateStatus();
    } else {
      _profile = null;
      _subscription = null;
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
        // Cargar suscripcion
        _subscription = await SubscriptionService.getSubscription();
        await SubscriptionService.checkAndUpdateStatus();
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
        // Iniciar trial para nuevo usuario
        _subscription = await SubscriptionService.startTrial();
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

  /// Envia email para restablecer contraseña
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.resetPasswordForEmail(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia la contraseña del usuario actual
  Future<void> updatePassword(String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza el email del usuario
  Future<void> updateEmail(String newEmail) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.updateUser(UserAttributes(email: newEmail));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene las identidades vinculadas del usuario
  List<UserIdentity> getLinkedIdentities() {
    return _user?.identities ?? [];
  }

  /// Vincula una identidad OAuth
  Future<void> linkIdentity(OAuthProvider provider) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.linkIdentity(provider);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Desvincula una identidad OAuth
  Future<void> unlinkIdentity(UserIdentity identity) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.unlinkIdentity(identity);
      // Recargar usuario
      await loadSession();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresca los datos del usuario
  Future<void> refreshUser() async {
    final session = _client.auth.currentSession;
    _user = session?.user;
    if (_user != null) {
      _profile = await _profileService.getCurrentProfile();
    }
    notifyListeners();
  }
}
