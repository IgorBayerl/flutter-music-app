import 'package:flutter/material.dart';

import '../../models/song.dart';

class AddSongPage extends StatefulWidget {
  const AddSongPage({Key? key}) : super(key: key);

  @override
  _AddSongPageState createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _sizeInBytesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Song'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _artistController,
              decoration: InputDecoration(
                labelText: 'Artist',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Duration (seconds)',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _sizeInBytesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Size (bytes)',
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                String title = _titleController.text;
                String artist = _artistController.text;
                int duration = int.tryParse(_durationController.text) ?? 0;
                int sizeInBytes =
                    int.tryParse(_sizeInBytesController.text) ?? 0;

                if (title.isNotEmpty &&
                    artist.isNotEmpty &&
                    duration > 0 &&
                    sizeInBytes > 0) {
                  Song song = Song(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    artist: artist,
                    duration: Duration(seconds: duration),
                    sizeInBytes: sizeInBytes,
                    album: '',
                    remotePath: '',
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields.'),
                    ),
                  );
                }
              },
              child: Text('Add Song'),
            ),
          ],
        ),
      ),
    );
  }
}
