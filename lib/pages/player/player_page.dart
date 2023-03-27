import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import '../../models/playlist.dart';
import '../../models/song.dart';
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
            PlaylistWidget(),
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
    final _pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
      valueListenable: _pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Text(title, style: TextStyle(fontSize: 20));
      },
    );
  }
}

class PlaylistWidget extends StatelessWidget {
  const PlaylistWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _pageManager = getIt<PageManager>();
    // final downloadService = getIt<DownloadService>();

    // TODO: when downloading a song, the list is updating wrong, if i download the third song, the first song on the list shows the name of the first one
    void handleDownload(int index) async {
      Song _currentSong =
          _pageManager.currentPlaylistNotifier.value.songs[index];
      await _currentSong.download();
      await _pageManager.updateMediaItem(_currentSong);
    }

    void handleDelete(int index) async {
      Song _currentSong =
          _pageManager.currentPlaylistNotifier.value.songs[index];
      await _currentSong.delete();
      await _pageManager.updateMediaItem(_currentSong);
    }

    void handlePlay(int index) {
      _pageManager.playFromMediaIndex(index);
    }

    //TODO: The state of the list is not updating correctly
   
    return Expanded(
      child: ValueListenableBuilder<Playlist>(
        valueListenable: _pageManager.currentPlaylistNotifier,
        builder: (context, playList, _) {
          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                Divider(thickness: 1),
            itemCount: playList.songs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => handlePlay(index),
                child: ListTile(
                  title: Text(
                    playList.songs[index].title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: playList.songs[index].isDownloaded
                      ? IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => handleDelete(index),
                        )
                      : IconButton(
                          icon: Icon(Icons.download),
                          onPressed: () => handleDownload(index),
                        ),
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
    final _pageManager = getIt<PageManager>();
    final _playlistService = getIt<PlaylistService>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _pageManager.clearQueue,
            child: Icon(Icons.clear),
          ),
          FloatingActionButton(
            onPressed: _pageManager.logPlaylist,
            child: Icon(Icons.login),
          ),

          // FloatingActionButton(
          //   onPressed: pageManager.add,
          //   child: Icon(Icons.add),
          // ),
          FloatingActionButton(
            onPressed: _pageManager.remove,
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
    final _pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: _pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: _pageManager.seek,
        );
      },
    );
  }
}
