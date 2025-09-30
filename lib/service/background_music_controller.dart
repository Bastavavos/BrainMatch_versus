import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final backgroundMusicProvider = StateNotifierProvider<BackgroundMusicController, double>(
      (ref) => BackgroundMusicController(),
);

class BackgroundMusicController extends StateNotifier<double> {
  final AudioPlayer _player = AudioPlayer();

  BackgroundMusicController() : super(1.0);

  /// Lancer la musique (à appeler après connexion réussie)
  Future<void> playMusic() async {
    try {
      await _player.setAsset('assets/audios/music.mp3'); // ton fichier
      _player.setLoopMode(LoopMode.all);                 // boucle infinie
      _player.setVolume(state);
      _player.play();
    } catch (e) {
      print("Erreur lecture audio: $e");
    }
  }

  /// Stopper la musique (à appeler lors de la déconnexion)
  void stop() => _player.stop();

  void setVolume(double volume) {
    state = volume;
    _player.setVolume(volume);
  }

  void toggleMute() {
    if (state > 0) {
      setVolume(0);      // mute → slider passe à 0
    } else {
      setVolume(0.5);    // unmute → valeur par défaut
    }
  }

  void pause() => _player.pause();
  void resume() => _player.play();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
