import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  void setServerUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('serverUrl', value);

    print('AAAAAAAAAAAAAAAAAAA');
    print(prefs.getString('serverUrl'));
  }

  Future<String> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('serverUrl') ?? '';
  }
}
