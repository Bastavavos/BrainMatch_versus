import 'dart:async';

import 'package:brain_match/ui/layout/special_layout.dart';
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
  int secondsLeft = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsLeft++;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Widget _buildPlayer(String name, String? pictureUrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: AppColors.light,
          backgroundImage: (pictureUrl != null && pictureUrl.isNotEmpty)
              ? NetworkImage(pictureUrl)
              : null,
          child: (pictureUrl == null || pictureUrl.isEmpty)
              ? const Icon(Icons.person, size: 70, color: AppColors.primary)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Luckiest Guy',
            fontSize: 30,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final String username = user?.username ?? 'Anonyme';
    final String? pictureUrl = user?.picture;

    return SpeLayout(
      child: Container(
        color: AppColors.primary,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPlayer(username, pictureUrl),
                const SizedBox(height: 40),
                Text(
                  "Recherche d'un joueur",
                  style: const TextStyle(
                    fontFamily: 'Luckiest Guy',
                    fontSize: 30,
                    color: AppColors.background,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$secondsLeft s',
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
