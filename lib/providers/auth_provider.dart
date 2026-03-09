import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import 'db_provider.dart';

enum AuthStatus { unknown, unauthenticated, manager, member }

class AuthState {
  final AuthStatus status;
  final String? userName;
  final String? messName;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userName,
    this.messName,
  });

  AuthState copyWith({AuthStatus? status, String? userName, String? messName}) =>
      AuthState(
        status: status ?? this.status,
        userName: userName ?? this.userName,
        messName: messName ?? this.messName,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkAuth();
    return const AuthState(status: AuthStatus.unknown);
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    final userType = prefs.getString('user_type') ?? '';
    final userName = prefs.getString('user_name') ?? '';
    final messName = prefs.getString('mess_name') ?? '';
    state = AuthState(
      status: userType == 'manager' ? AuthStatus.manager : AuthStatus.member,
      userName: userName,
      messName: messName,
    );
  }

  Future<String?> setupMess({
    required String managerName,
    required String messName,
    required String messCode,
    required String password,
    required String ref2,
  }) async {
    final db = ref.read(dbHelperProvider);
    try {
      await db.setConfig('manager_name', managerName);
      await db.setConfig('mess_name', messName);
      await db.setConfig('mess_code', messCode);
      await db.setConfig('manager_password', password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_type', 'manager');
      await prefs.setString('user_name', managerName);
      await prefs.setString('mess_name', messName);

      state = AuthState(
        status: AuthStatus.manager,
        userName: managerName,
        messName: messName,
      );
      return null;
    } catch (e) {
      return 'সেটআপ ব্যর্থ: $e';
    }
  }

  Future<String?> loginManager({required String password}) async {
    final db = ref.read(dbHelperProvider);
    try {
      final storedPassword = await db.getConfig('manager_password');
      if (storedPassword != password) {
        return 'পাসওয়ার্ড ভুল';
      }
      final managerName = await db.getConfig('manager_name') ?? '';
      final messName = await db.getConfig('mess_name') ?? '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_type', 'manager');
      await prefs.setString('user_name', managerName);
      await prefs.setString('mess_name', messName);

      state = AuthState(
        status: AuthStatus.manager,
        userName: managerName,
        messName: messName,
      );
      return null;
    } catch (e) {
      return 'লগইন ব্যর্থ: $e';
    }
  }

  Future<String?> joinMess({
    required String name,
    required String phone,
    required String email,
    required String messCode,
  }) async {
    final db = ref.read(dbHelperProvider);
    try {
      final storedCode = await db.getConfig('mess_code');
      if (storedCode != messCode) {
        return 'মেস কোড ভুল';
      }
      final messName = await db.getConfig('mess_name') ?? '';

      // Add as member
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await db.insertMember(
        Member(
          name: name,
          phone: phone,
          email: email,
          joinDate: dateStr,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_type', 'member');
      await prefs.setString('user_name', name);
      await prefs.setString('mess_name', messName);

      state = AuthState(
        status: AuthStatus.member,
        userName: name,
        messName: messName,
      );
      return null;
    } catch (e) {
      return 'যোগ দেওয়া ব্যর্থ: $e';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Convenience provider to check if setup is done
final isSetupDoneProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(dbHelperProvider);
  return db.isSetupDone();
});
