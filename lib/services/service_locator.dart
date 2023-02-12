import 'package:audio_service/audio_service.dart';
import 'package:flutter_audio_service_demo/services/settings_service.dart';

import 'download_service.dart';
import 'page_manager.dart';
import 'audio_handler.dart';
import 'playlist_repository.dart';
import 'package:get_it/get_it.dart';

import 'playlist_service.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  getIt.registerSingleton<SettingsService>(SettingsService());
  getIt.registerSingleton<AudioHandler>(await initAudioService());
  getIt.registerLazySingleton<PlaylistRepository>(() => Playlist());
  getIt.registerLazySingleton<PlaylistService>(() => PlaylistService());
  getIt.registerLazySingleton<DownloadService>(() => DownloadService());
  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}
