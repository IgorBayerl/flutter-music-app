import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/download_service.dart';
import '../../services/service_locator.dart';

class DownloadedSongsWidget extends StatefulWidget {
  @override
  _DownloadedSongsWidgetState createState() => _DownloadedSongsWidgetState();
}

class _DownloadedSongsWidgetState extends State<DownloadedSongsWidget> {
  final DownloadService downloadService = DownloadService();
  List<String> downloadedMusics = [];

  @override
  void initState() {
    super.initState();
    _loadDownloadedMusics();
  }

  Future<void> _loadDownloadedMusics() async {
    try {
      List<String> downloadedPaths =
          await downloadService.getDownloadedMusics();
      setState(() {
        downloadedMusics = downloadedPaths;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Downloaded Songs'),
      ),
      body: ListView.builder(
        itemCount: downloadedMusics.length,
        itemBuilder: (BuildContext context, int index) {
          String musicPath = downloadedMusics[index];
          String musicTitle = musicPath;
          return ListTile(
            title: Text(musicTitle),
            subtitle: Text(musicPath),
            onTap: () {
              // Handle onTap event
            },
          );
        },
      ),
    );
  }
}
