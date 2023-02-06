import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import '../../notifiers/progress_notifier.dart';
import '../../services/page_manager.dart';
import '../../services/playlist_service.dart';
import '../../services/service_locator.dart';
import 'audio_control_buttons.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CurrentSongTitle(),
            Playlist(),
            AddRemoveSongButtons(),
            AudioProgressBar(),
            AudioControlButtons(),
          ],
        ),
      ),
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Text(title, style: TextStyle(fontSize: 20));
      },
    );
  }
}

class Playlist extends StatelessWidget {
  const Playlist({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return Expanded(
      child: ValueListenableBuilder<List<Song>>(
        valueListenable: pageManager.playlistNotifier,
        builder: (context, playlistTitles, _) {
          return ListView.builder(
            itemCount: playlistTitles.length,
            itemBuilder: (context, index) {
              return Container(
                color: index % 2 == 0 ? Colors.grey[300] : Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(playlistTitles[index].title),
                      subtitle: Text(playlistTitles[index].album),
                    ),
                    Text(playlistTitles[index].url)
                    // TextButton(
                    //   onPressed: () => print(index),
                    //   child: Text('Download'),
                    // ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddRemoveSongButtons extends StatelessWidget {
  const AddRemoveSongButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    final playlistService = getIt<PlaylistService>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: pageManager.add,
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: pageManager.remove,
            child: Icon(Icons.remove),
          ),
          // FloatingActionButton(
          //   onPressed: () => playlistService.printPlaylist(),
          //   child: Icon(Icons.save),
          // ),
          // FloatingActionButton(
          //   onPressed: () {
          //     final playlist = pageManager.playlistNotifier;
          //     playlistService.savePlaylist(playlist);
          //   },
          //   child: Icon(Icons.upload),
          // ),
          // FloatingActionButton(
          //   onPressed: () => playlistService.printPlaylist(),
          //   child: Icon(Icons.info),
          // ),
        ],
      ),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: pageManager.seek,
        );
      },
    );
  }
}
