import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // final myTextController = TextEditingController();
  TextEditingController myTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // myTextController.text = 'aaaa';
    final prefs = SharedPreferences.getInstance();
    prefs.then(
      (value) => {
        myTextController.text = value.getString('serverUrl') ?? '',
      },
    );

    // serverUrl.then((value) => myTextController.text = value);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextField(
                  controller: myTextController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Audio URL',
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('serverUrl', myTextController.text);
            Navigator.pop(context);
          },
          tooltip: 'Show me the value!',
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
