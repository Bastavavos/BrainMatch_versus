// import 'package:flutter/material.dart';
//
// class WaitingView extends StatelessWidget {
//   const WaitingView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           'En attente d’un adversaire...',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/user_provider.dart';
import '../../theme.dart';

class WaitingView extends ConsumerStatefulWidget {
  const WaitingView({super.key});

  @override
  ConsumerState<WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends ConsumerState<WaitingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsController;
  late Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _dotAnimation = IntTween(begin: 0, end: 3).animate(_dotsController);
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    final String username = user?['username'] ?? 'Joueur';
    final String? pictureUrl = user?['picture'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profil utilisateur
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: pictureUrl != null && pictureUrl.isNotEmpty
                      ? NetworkImage(pictureUrl)
                      : null,
                  child: (pictureUrl == null || pictureUrl.isEmpty)
                      ? const Icon(Icons.person, size: 48, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Animation de texte
            AnimatedBuilder(
              animation: _dotAnimation,
              builder: (context, child) {
                String dots = '.' * _dotAnimation.value;
                return Text(
                  'En attente d’un adversaire$dots',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.secondaryAccent,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            const CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
