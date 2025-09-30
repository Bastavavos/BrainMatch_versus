import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/background_music_controller.dart';

final backgroundMusicProvider =
StateNotifierProvider<BackgroundMusicController, double>(
      (ref) => BackgroundMusicController(),
);