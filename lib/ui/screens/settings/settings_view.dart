import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';

import '../../../provider/user_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../../service/api_service.dart';
import '../../layout/special_layout.dart';
import '../../theme.dart';
import '../../../provider/background_music_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final token = ref.read(tokenProvider);
    final baseUrl = dotenv.env['API_KEY'];

    if (token != null && baseUrl != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/user/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (e) {
        debugPrint("Erreur logout: $e");
      }
    }

    // reset user et token
    ref.read(currentUserProvider.notifier).setUser(null);
    ref.read(tokenProvider.notifier).state = null;

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupère l'état (volume) et le contrôleur
    final volume = ref.watch(backgroundMusicProvider);
    final musicController = ref.read(backgroundMusicProvider.notifier);

    return SpeLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text("General",
                style: TextStyle(
                    fontSize: 24,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Luckiest Guy'
                )),
            const SizedBox(height: 12),
            const ListTile(
              title: Text("Notifications",
                  style: TextStyle(
                      fontFamily: 'Mulish'
                  )),
              trailing: Icon(Icons.arrow_forward_ios),
              leading: Icon(Icons.browse_gallery_outlined),
            ),
            const ListTile(
              title: Text("Données personnelles",
                  style: TextStyle(
                      fontFamily: 'Mulish'
                  )),
              trailing: Icon(Icons.arrow_forward_ios),
              leading: Icon(Icons.collections_bookmark_rounded),
            ),
            const SizedBox(height: 12),
            const Text("Sons",
                style: TextStyle(
                    fontSize: 24,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Luckiest Guy')),

            ListTile(
              leading: Icon(volume > 0 ? Icons.volume_up : Icons.volume_off),
              subtitle: Slider(
                value: volume,
                min: 0,
                max: 1,
                divisions: 10,
                label: (volume * 100).toInt().toString(),
                onChanged: (val) => musicController.setVolume(val),
              ),
              trailing: IconButton(
                icon: Icon(volume > 0 ? Icons.volume_mute : Icons.volume_up),
                onPressed: () {
                  if (volume > 0) {
                    // mute total → slider se met à 0
                    musicController.setVolume(0);
                  } else {
                    // si déjà à 0 → remet à un volume par défaut (ex : 0.5)
                    musicController.setVolume(0.5);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text("Aide & Support",
                style: TextStyle(
                    fontSize: 24,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Luckiest Guy')),
            const SizedBox(height: 12),
            const ListTile(
              title: Text("Sécurité",
                  style: TextStyle(
                      fontFamily: 'Mulish'
                  )),
              trailing: Icon(Icons.arrow_forward_ios),
              leading: Icon(Icons.security),
            ),
            const SizedBox(height: 12),
            const ListTile(
              title: Text("À propos",
                  style: TextStyle(
                      fontFamily: 'Mulish'
                  )),
              trailing: Icon(Icons.arrow_forward_ios),
              leading: Icon(Icons.info_outline_rounded),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _logout(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Déconnexion",
                  style: TextStyle(fontSize: 18, fontFamily: 'Mulish'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
