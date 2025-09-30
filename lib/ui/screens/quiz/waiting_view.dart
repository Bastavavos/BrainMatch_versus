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

  Widget _buildPlayer(String name, String? pictureUrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final String username = user?.username ?? 'Joueur';
    final String? pictureUrl = user?.picture;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
