import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  static SharedPreferences? _prefs;

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyToken = 'token';
  static const String _keyUserType = 'user_type';

  SharedPrefsService._internal();

  static SharedPrefsService get instance => _instance;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ------------------ Login ------------------
  Future<void> setLoginStatus(bool isLoggedIn) async {
    await _prefs?.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  bool getLoginStatus() {
    return _prefs?.getBool(_keyIsLoggedIn) ?? false;
  }

  // ------------------ Token ------------------
  Future<void> setToken(String token) async {
    await _prefs?.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  // ------------------ User Type ------------------
  Future<void> setUserType(String type) async {
    await _prefs?.setString(_keyUserType, type);
  }

  String? getUserType() {
    return _prefs?.getString(_keyUserType);
  }

  // ------------------ Language ------------------
  Future<void> setLanguageCode(String code) async {
    await _prefs?.setString(_keyLanguageCode, code);
  }

  String getLanguageCode() {
    return _prefs?.getString(_keyLanguageCode) ?? 'ar';
  }

Future<void> setLastSelectedStudentId(String id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("last_student_id", id);
}

String getLastSelectedStudentId() {
    return _prefs?.getString("last_student_id") ?? '';
  }
  // ------------------ Clear All ------------------
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
