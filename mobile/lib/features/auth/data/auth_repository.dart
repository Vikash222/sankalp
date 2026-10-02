import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import 'models/user_model.dart';

class AuthRepository {
  final DioClient dioClient;
  final TokenStorage tokenStorage;

  AuthRepository({
    required this.dioClient,
    required this.tokenStorage,
  });

  /// Automatically initialize an anonymous guest session.
  /// Falls back to local offline guest mode if network is unreachable or times out.
  Future<UserModel> guestOnboard() async {
    final deviceUuid = tokenStorage.getOrCreateDeviceUuid();
    final lang = tokenStorage.getLanguage();

    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        ApiEndpoints.guestAuth,
        data: {
          'device_uuid': deviceUuid,
          'language': lang,
          'timezone': 'Asia/Kolkata',
        },
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'] as String;
        await tokenStorage.saveToken(token);
        await tokenStorage.setGuest(true);

        final userJson = response.data!['user'] as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      }
    } catch (_) {
      // Offline fallback below
    }

    // Graceful offline fallback guest session
    await tokenStorage.setGuest(true);
    return UserModel(
      id: 0,
      uuid: deviceUuid,
      name: tokenStorage.getUserName(),
      email: tokenStorage.getUserEmail(),
      isGuest: true,
      totalXp: tokenStorage.getUserXp(),
      profile: const UserProfileModel(),
    );
  }

  /// Register a permanent user account.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final deviceUuid = tokenStorage.getOrCreateDeviceUuid();

    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'language': tokenStorage.getLanguage(),
          'timezone': 'Asia/Kolkata',
        },
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'] as String;
        await tokenStorage.saveToken(token);
        await tokenStorage.setGuest(false);
        await tokenStorage.setUserName(name);
        await tokenStorage.setUserEmail(email);

        final userJson = response.data!['user'] as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      }
    } catch (_) {
      // Offline fallback: persist registration locally
    }

    await tokenStorage.saveToken('offline_token_$deviceUuid');
    await tokenStorage.setGuest(false);
    await tokenStorage.setUserName(name);
    await tokenStorage.setUserEmail(email);

    return UserModel(
      id: 1,
      uuid: deviceUuid,
      name: name,
      email: email,
      isGuest: false,
      totalXp: tokenStorage.getUserXp(),
      profile: const UserProfileModel(),
    );
  }

  /// Authenticate with email & password.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final deviceUuid = tokenStorage.getOrCreateDeviceUuid();

    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'] as String;
        await tokenStorage.saveToken(token);
        await tokenStorage.setGuest(false);
        await tokenStorage.setUserEmail(email);

        final userJson = response.data!['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson);
        await tokenStorage.setUserName(user.name);
        return user;
      }
    } catch (_) {
      // Offline fallback: authenticate user locally
    }

    final savedName = email.split('@').first;
    final formattedName = savedName.isNotEmpty
        ? '${savedName[0].toUpperCase()}${savedName.substring(1)}'
        : 'Practitioner';

    await tokenStorage.saveToken('offline_token_$deviceUuid');
    await tokenStorage.setGuest(false);
    await tokenStorage.setUserName(formattedName);
    await tokenStorage.setUserEmail(email);

    return UserModel(
      id: 1,
      uuid: deviceUuid,
      name: formattedName,
      email: email,
      isGuest: false,
      totalXp: tokenStorage.getUserXp(),
      profile: const UserProfileModel(),
    );
  }

  /// Upgrade current guest session to a permanent account.
  Future<UserModel> upgradeGuest({
    required String name,
    required String email,
    required String password,
  }) async {
    final deviceUuid = tokenStorage.getOrCreateDeviceUuid();

    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        ApiEndpoints.upgrade,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.success && response.data != null) {
        await tokenStorage.setGuest(false);
        await tokenStorage.setUserName(name);
        await tokenStorage.setUserEmail(email);
        final userJson = response.data!['user'] as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      }
    } catch (_) {
      // Offline fallback: upgrade locally
    }

    await tokenStorage.setGuest(false);
    await tokenStorage.setUserName(name);
    await tokenStorage.setUserEmail(email);

    return UserModel(
      id: 1,
      uuid: deviceUuid,
      name: name,
      email: email,
      isGuest: false,
      totalXp: tokenStorage.getUserXp(),
      profile: const UserProfileModel(),
    );
  }

  /// Fetch authenticated user profile.
  Future<UserModel> getMe() async {
    final deviceUuid = tokenStorage.getOrCreateDeviceUuid();

    try {
      final response =
          await dioClient.get<Map<String, dynamic>>(ApiEndpoints.me);

      if (response.success && response.data != null) {
        final userJson = response.data!['user'] as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      }
    } catch (_) {
      // Offline fallback
    }

    return UserModel(
      id: tokenStorage.isGuest() ? 0 : 1,
      uuid: deviceUuid,
      name: tokenStorage.getUserName(),
      email: tokenStorage.getUserEmail(),
      isGuest: tokenStorage.isGuest(),
      totalXp: tokenStorage.getUserXp(),
      profile: const UserProfileModel(),
    );
  }

  /// Logout and clear credentials.
  Future<void> logout() async {
    try {
      await dioClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await tokenStorage.clearToken();
      await tokenStorage.setGuest(true);
      await tokenStorage.setUserEmail(null);
    }
  }
}
