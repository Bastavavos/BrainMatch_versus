import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/user_provider.dart';
import '../../theme.dart';

// class WaitingView extends ConsumerStatefulWidget {
//   const WaitingView({super.key});
//
//   @override
//   ConsumerState<WaitingView> createState() => _WaitingViewState();
// }

class WaitingView extends ConsumerStatefulWidget {
  final Map<String, dynamic>? opponent;

  const WaitingView({super.key, this.opponent});

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

  // @override
  // Widget build(BuildContext context) {
  //   final user = ref.watch(userProvider);
  //   final String username = user?['username'] ?? 'Joueur';
  //   final String? pictureUrl = user?['picture'];
  //
  //   return Scaffold(
  //     backgroundColor: AppColors.primary,
  //     body: SafeArea(
  //       child: Center(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             // Avatar utilisateur
  //             CircleAvatar(
  //               radius: 50,
  //               backgroundColor: AppColors.light,
  //               backgroundImage: (pictureUrl != null && pictureUrl.isNotEmpty)
  //                   ? NetworkImage(pictureUrl)
  //                   : null,
  //               child: (pictureUrl == null || pictureUrl.isEmpty)
  //                   ? const Icon(Icons.person, size: 50, color: AppColors.primary)
  //                   : null,
  //             ),
  //
  //             const SizedBox(height: 16),
  //
  //             // Nom utilisateur
  //             Text(
  //               username,
  //               style: const TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //
  //             const SizedBox(height: 40),
  //
  //             // Texte animé
  //             AnimatedBuilder(
  //               animation: _dotAnimation,
  //               builder: (context, child) {
  //                 String dots = '.' * _dotAnimation.value;
  //                 return Text(
  //                   'En attente d’un adversaire$dots',
  //                   style: const TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w500,
  //                     color: AppColors.secondaryAccent,
  //                   ),
  //                 );
  //               },
  //             ),
  //
  //             const SizedBox(height: 20),
  //
  //             const CircularProgressIndicator(
  //               color: AppColors.accent,
  //               strokeWidth: 3,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildPlayer(String name, String? pictureUrl) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.light,
          backgroundImage: (pictureUrl != null && pictureUrl.isNotEmpty)
              ? NetworkImage(pictureUrl)
              : null,
          child: (pictureUrl == null || pictureUrl.isEmpty)
              ? const Icon(Icons.person, size: 40, color: AppColors.primary)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final String username = user?['username'] ?? 'Joueur';
    final String? pictureUrl = user?['picture'];

    final opponent = widget.opponent;
    final String? opponentName = opponent?['username'];
    final String? opponentPicture = opponent?['picture'];

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎭 Si adversaire trouvé, on affiche les 2 joueurs
              if (opponent != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPlayer(username, pictureUrl),
                    const SizedBox(width: 30),
                    const Icon(Icons.sports_esports, color: AppColors.accent, size: 30),
                    const SizedBox(width: 30),
                    _buildPlayer(opponentName ?? "Adversaire", opponentPicture),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  "Préparation du duel...",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ] else ...[
                _buildPlayer(username, pictureUrl),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _dotAnimation,
                  builder: (context, child) {
                    String dots = '.' * _dotAnimation.value;
                    return Text(
                      'En attente d’un adversaire$dots',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryAccent,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 3,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

