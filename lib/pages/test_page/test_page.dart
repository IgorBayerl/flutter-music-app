import 'package:flutter/material.dart';

import '../../models/Playlist.dart';
import '../../models/song.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final List<Song> _songs = [
    Song(
      id: '1',
      title: 'Song 1',
      album: 'Album 1',
      artist: 'Artist 1',
      remotePath: 'https://example.com/song1.mp3',
      duration: Duration(seconds: 180),
      sizeInBytes: 5000000,
    ),
    Song(
      id: '2',
      title: 'Song 2',
      album: 'Album 2',
      artist: 'Artist 2',
      remotePath: 'https://example.com/song2.mp3',
      duration: Duration(seconds: 240),
      sizeInBytes: 8000000,
    ),
    Song(
      id: '3',
      title: 'Song 3',
      album: 'Album 3',
      artist: 'Artist 3',
      remotePath: 'https://example.com/song3.mp3',
      duration: Duration(seconds: 300),
      sizeInBytes: 10000000,
    ),
  ];

  final Playlist _playlist = Playlist(
    id: '1',
    title: 'My Playlist',
    songs: [],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Download a song
                _songs[0].download().then((success) {
                  if (success) {
                    print('Song downloaded successfully');
                  } else {
                    print('Failed to download song');
                  }
                });
              },
              child: Text('Download Song'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add a song to the playlist
                setState(() {
                  _playlist.addSong(_songs[0]);
                });
              },
              child: Text('Add Song to Playlist'),
            ),
            ElevatedButton(
              onPressed: () {
                // Remove a song from the playlist
                setState(() {
                  _playlist.removeSong('1');
                });
              },
              child: Text('Remove Song from Playlist'),
            ),
            Text(
              'Playlist Name: ${_playlist.title}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _playlist.songs.length,
                itemBuilder: (context, index) {
                  final Song song = _playlist.songs[index];
                  return ListTile(
                    title: Text(song.title),
                    subtitle: Text(song.artist),
                    onTap: () {
                      // Play the song
                      print('Playing ${song.title}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
