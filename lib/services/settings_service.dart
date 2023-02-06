import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _serverUrlKey = 'server_url';

  Future<void> setMusicServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
  }

  Future<String> getMusicServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverUrlKey) ?? '';
  }
}
