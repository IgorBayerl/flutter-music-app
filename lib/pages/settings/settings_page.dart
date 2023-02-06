import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  late SettingsService _settingsService;

  @override
  void initState() {
    super.initState();
    _settingsService = GetIt.instance<SettingsService>();
    _loadServerUrl();
  }

  void _loadServerUrl() async {
    final serverUrl = await _settingsService.getMusicServerUrl();
    _controller.text = serverUrl;
  }

  _handleSave() async {
    if (_formKey.currentState!.validate()) {
      await _settingsService.setMusicServerUrl(_controller.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Saved!')),
      );
    }
  }

  _handleTestMethod() async {
    print('test method');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a server URL';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            FloatingActionButton(
              onPressed: _handleSave,
              child: Text('Save'),
            ),
            FloatingActionButton(
              onPressed: _handleTestMethod,
              child: Text('Test Method'),
            ),
          ],
        ),
      ),
    );
  }
}
