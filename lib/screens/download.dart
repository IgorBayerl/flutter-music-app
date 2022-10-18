import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_service_demo/page_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/service_locator.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  // final myTextController = TextEditingController();
  TextEditingController myTextController = TextEditingController();

  Future<File?> downloadFile(String url, String name) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/$name');

    try {
      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: 0,
        ),
      );

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      print('aaaa ${file.path}');

      return file;
    } catch (e) {
      AlertDialog(
        title: Text('Error'),
        content: Text('Error downloading file'),
      );
      return null;
    }
  }

  Future openFile({required String url, String? fileName}) async {
    String fileNames = url.split('/')[url.split('/').length - 1];
    await downloadFile(url, fileNames);
  }

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
    final pageManager = getIt<PageManager>();
    Future<List<Map<String, String>>> _downloadedFiles() async {
      print('_downloadedFiles');
      final appStorage = await getApplicationDocumentsDirectory();
      final files = appStorage.listSync();
      final filesList = <Map<String, String>>[];

      for (final file in files) {
        /// add only mp3 files

        if (file.path.endsWith('.mp3')) {
          filesList.add({
            'name': file.path.split('/').last,
            'path': file.path,
          });
        }
      }

      return filesList;

      // return Future.value(
      //   [
      //     {
      //       'name': 'file1',
      //       'url': 'asdasd',
      //     },
      //     {
      //       'name': 'file2',
      //       'url': 'asdasd',
      //     },
      //   ],
      // );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Download'),
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
                    labelText: 'Url',
                  ),
                ),
                FloatingActionButton(
                  key: Key('downloadButton'),
                  onPressed: () {
                    print('AAAAA');
                    openFile(url: myTextController.text, fileName: 'test.mp3');
                  },
                  child: Icon(Icons.download),
                ),
                FutureBuilder(
                  future: _downloadedFiles(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(snapshot.data[index]['name']),
                            onTap: () => pageManager.playThisSong(
                              snapshot.data[index]['path'],
                            ),
                          );
                        },
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
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
