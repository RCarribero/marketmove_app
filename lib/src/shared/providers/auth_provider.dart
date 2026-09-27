import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../../features/pricing/services/subscription_service.dart';
import '../../features/pricing/models/pricing_plan.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient? _client;
  final ProfileService _profileService;

  AuthProvider([this._client, ProfileService? profileService])
      : _profileService = profileService ?? ProfileService(_client);

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

  /// Carga la sesión actual y el perfil del usuario (con sesión demo embebida).
  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = _client?.auth.currentSession;
      _user = session?.user;

      if (_user != null) {
        _profile = await _profileService.getCurrentProfile();
        _subscription = await SubscriptionService.getSubscription();
        await SubscriptionService.checkAndUpdateStatus();
      } else {
        // En modo demo sin base de datos activa, precargamos la sesión de administrador
        _user = User(
          id: 'demo-admin-user',
          appMetadata: const {},
          userMetadata: const {'name': 'Rubén Carribero (Demo)'},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: 'admin@marketmove.app',
        );
        _profile = await _profileService.getCurrentProfile();
        _subscription = UserSubscription(
          odId: 'demo-admin-user',
          planId: 'pro',
          status: SubscriptionStatus.active,
          subscriptionStartDate: DateTime.now().subtract(const Duration(days: 15)),
          subscriptionEndDate: DateTime.now().add(const Duration(days: 350)),
          isAnnual: true,
        );
      }
    } catch (_) {
      _profile = await _profileService.getCurrentProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final isClient = !email.toLowerCase().contains('admin');
      final activeUserId = isClient ? 'demo-client-user' : 'demo-admin-user';
      final activeEmail = email.isNotEmpty ? email : (isClient ? 'cliente@marketmove.app' : 'admin@marketmove.app');

      if (_client != null) {
        try {
          final response = await _client.auth.signInWithPassword(
            email: email,
            password: password,
          );
          _user = response.user;
        } catch (_) {
          _user = null;
        }
      }

      _user ??= User(
        id: activeUserId,
        appMetadata: const {},
        userMetadata: {'name': isClient ? 'Laura Gómez (Cliente)' : 'Carlos Director (Admin)'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: activeEmail,
      );

      _profile = await _profileService.getCurrentProfile(activeEmail);
      _subscription = await SubscriptionService.getSubscription() ??
          UserSubscription(
            odId: activeUserId,
            planId: isClient ? 'free' : 'pro',
            status: SubscriptionStatus.active,
            subscriptionStartDate: DateTime.now().subtract(const Duration(days: 15)),
            subscriptionEndDate: DateTime.now().add(const Duration(days: 350)),
            isAnnual: !isClient,
          );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_client != null) {
        try {
          final response = await _client.auth.signUp(
            email: email,
            password: password,
          );
          _user = response.user;
        } catch (_) {
          _user = null;
        }
      }

      _user ??= User(
        id: 'demo-admin-user',
        appMetadata: const {},
        userMetadata: const {'name': 'Nuevo Usuario'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      );

      _profile = await _profileService.getCurrentProfile();
      _subscription = await SubscriptionService.startTrial();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_client != null) {
        await _client.auth.signInWithOAuth(OAuthProvider.google);
      } else {
        await signIn('google.user@marketmove.app', '');
      }
    } catch (_) {
      await signIn('google.user@marketmove.app', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _client?.auth.signOut();
    } catch (_) {}
    _user = null;
    _profile = null;
    _subscription = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _client?.auth.resetPasswordForEmail(email);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _client?.auth.updateUser(UserAttributes(password: newPassword));
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateEmail(String newEmail) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _client?.auth.updateUser(UserAttributes(email: newEmail));
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  List<UserIdentity> getLinkedIdentities() {
    return _user?.identities ?? [];
  }

  Future<void> linkIdentity(OAuthProvider provider) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _client?.auth.linkIdentity(provider);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> unlinkIdentity(UserIdentity identity) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _client?.auth.unlinkIdentity(identity);
      await loadSession();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final session = _client?.auth.currentSession;
      _user = session?.user ?? _user;
      if (_user != null) {
        _profile = await _profileService.getCurrentProfile();
      }
    } catch (_) {}
    notifyListeners();
  }
}
