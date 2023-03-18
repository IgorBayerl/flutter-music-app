import 'package:flutter/material.dart';
import '../../models/song.dart';

class AddSongPage extends StatefulWidget {
  @override
  _AddSongPageState createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _album;
  late String _artist;
  late String _remotePath;
  late String _songServerUrl;
  late Duration _duration;
  late int _sizeInBytes;
  late String _artworkUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Song'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: 'Title Test',
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),
                TextFormField(
                  initialValue: 'Album Test',
                  decoration: InputDecoration(labelText: 'Album'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an album';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _album = value!;
                  },
                ),
                TextFormField(
                  initialValue: 'Artist Test',
                  decoration: InputDecoration(labelText: 'Artist'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an artist';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _artist = value!;
                  },
                ),
                TextFormField(
                  initialValue: 'Remote Path Test',
                  decoration: InputDecoration(labelText: 'Remote Path'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a remote path';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _remotePath = value!;
                  },
                ),
                TextFormField(
                  initialValue: 'Song Server URL Test',
                  decoration: InputDecoration(labelText: 'Song Server URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a song server URL';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _songServerUrl = value!;
                  },
                ),
                TextFormField(
                  initialValue: '30',
                  decoration: InputDecoration(labelText: 'Duration'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a duration';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _duration = Duration(seconds: int.parse(value!));
                  },
                ),
                TextFormField(
                  initialValue: '50',
                  decoration: InputDecoration(labelText: 'Size in Bytes'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a size in bytes';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _sizeInBytes = int.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: 'Artwork URL Test',
                  decoration: InputDecoration(labelText: 'Artwork URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an artwork URL';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _artworkUrl = value!;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      print('Submit button pressed');
                      print('>>>> 0');
                      if (_formKey.currentState!.validate()) {
                        print('>>>> 1');
                        _formKey.currentState!.save();
                        print('>>>> 2');
                        final song = Song(
                          id: UniqueKey().toString(),
                          title: _title,
                          album: _album,
                          artist: _artist,
                          remotePath: _remotePath,
                          songServerUrl: _songServerUrl,
                          duration: _duration,
                          sizeInBytes: _sizeInBytes,
                          artworkUrl: _artworkUrl,
                        );
                        print('>>>> 3');
                        Navigator.pop(context, song);
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
