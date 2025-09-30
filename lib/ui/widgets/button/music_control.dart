import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/background_music_provider.dart';

class MusicControlWidget extends ConsumerWidget {
  const MusicControlWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(backgroundMusicProvider);
    final controller = ref.read(backgroundMusicProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(volume > 0 ? Icons.volume_up : Icons.volume_off),
          onPressed: () => controller.toggleMute(),
        ),
        Expanded(
          child: Slider(
            value: volume,
            min: 0,
            max: 1,
            divisions: 10,
            label: (volume * 100).toInt().toString(),
            onChanged: (val) => controller.setVolume(val),
          ),
        ),
      ],
    );
  }
}
