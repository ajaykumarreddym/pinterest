import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appStorageProvider = Provider<AppStorage>((ref) {
  throw UnimplementedError(
    'appStorageProvider must be overridden with SharedPreferences instance',
  );
});

/// Abstraction over local key-value storage.
class AppStorage {
  const AppStorage(this._prefs);

  final SharedPreferences _prefs;

  // String
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  // Bool
  Future<bool> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  // Int
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  // List<String>
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  // Remove
  Future<bool> remove(String key) => _prefs.remove(key);

  // Clear
  Future<bool> clear() => _prefs.clear();

  // Contains
  bool containsKey(String key) => _prefs.containsKey(key);
}
