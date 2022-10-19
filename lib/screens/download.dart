import 'dart:ffi';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
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
  TextEditingController myTextController2 = TextEditingController();
  bool _isDownloading = false;

  Future<File?> downloadFile(String url, String name) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/$name');

    try {
      setState(() {
        _isDownloading = true;
      });
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
      setState(() {
        _isDownloading = false;
      });
      return file;
    } catch (e) {
      AlertDialog(
        title: Text('Error'),
        content: Text('Error downloading file'),
      );
      setState(() {
        _isDownloading = false;
      });
      return null;
    }
  }

  Future openFile({required String url, required String fileName}) async {
    await downloadFile(url, fileName);
  }

  Future deleteFile({required String fileName}) async {
    setState(() {
      _isDownloading = true;
    });
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/$fileName');
    file.delete();
    setState(() {
      _isDownloading = false;
    });
  }

  Future clearQueue() async {
    final _audioHandler = getIt<AudioHandler>();
    await _audioHandler.stop();
    for (int i = 0; i < _audioHandler.queue.value.length; i++) {
      final lastIndex = _audioHandler.queue.value.length - 1;
      if (lastIndex < 0) return;
      _audioHandler.removeQueueItemAt(lastIndex);
    }
  }

  @override
  void initState() {
    super.initState();

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
                  controller: myTextController2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'File Name',
                  ),
                ),
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
                    openFile(
                        url: myTextController.text,
                        fileName: myTextController2.text + '.mp3');
                  },
                  child: Icon(Icons.download),
                ),
                FloatingActionButton(
                  key: Key('clearQueueButton'),
                  onPressed: () {
                    print('clearQueueButton pressed');
                    clearQueue();
                  },
                  child: Icon(Icons.clear_all),
                ),
                Visibility(
                  visible: _isDownloading,
                  child: CircularProgressIndicator(),
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
                            onTap: () => {
                              print('PlayingLocalMusic ================> '),
                              print(snapshot.data[index]['path']),
                              pageManager.playThisSong(
                                'file://' + snapshot.data[index]['path'],
                              ),
                              pageManager.play(),
                            },
                            onLongPress: () {
                              deleteFile(
                                fileName: snapshot.data[index]['name'] + '.mp3',
                              );
                            },
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
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {

        //     Navigator.pop(context);
        //   },
        //   tooltip: 'Show me the value!',
        //   child: const Icon(Icons.arrow_back),
        // ),
      ),
    );
  }
}
