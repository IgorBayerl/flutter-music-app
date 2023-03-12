import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import '../../interfaces/Song.dart';
import '../../notifiers/progress_notifier.dart';
import '../../services/download_service.dart';
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
    final downloadService = getIt<DownloadService>();

    void handleDownload(int index) async {
      print('Download button pressed for song at index $index');
      final song = pageManager.playlistNotifier.value[index];
      await downloadService.downloadMusic(song.remotePath);
      print('Download is complete for song at index $index');
    }

    void handleDelete(int index) async {
      print('Delete button pressed for song at index $index');
      final song = pageManager.playlistNotifier.value[index];
      await downloadService.deleteMusic(song.localPath);
      print('Delete is complete for song at index $index');
    }

    void handlePlay(int index) {
      pageManager.playFromMediaId(index);
    }

    return Expanded(
      child: ValueListenableBuilder<List<Song>>(
        valueListenable: pageManager.playlistNotifier,
        builder: (context, playlistTitles, _) {
          return ListView.builder(
            itemCount: playlistTitles.length,
            itemBuilder: (context, index) {
              //TODO: Each item will be a button that will play the song
              return Container(
                color: index % 2 == 0 ? Colors.grey[300] : Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(playlistTitles[index].title),
                      subtitle: Text(playlistTitles[index].album),
                    ),
                    // TODO:remove this lines
                    Text(playlistTitles[index].localPath),
                    Text(playlistTitles[index].remotePath),
                    if (playlistTitles[index].localPath.isEmpty)
                      TextButton(
                        onPressed: () => handleDownload(index),
                        child: Text('Download'),
                      )
                    else
                      TextButton(
                        onPressed: () => handleDelete(index),
                        child: Text('Delete'),
                      ),
                    TextButton(
                      onPressed: () => handlePlay(index),
                      child: Text('Play'),
                    )
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
