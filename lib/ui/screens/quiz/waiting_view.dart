import 'dart:async';

import 'package:brain_match/ui/layout/special_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/user_provider.dart';
import '../../theme.dart';

class WaitingView extends ConsumerStatefulWidget {
  final String categoryName;

  const WaitingView({super.key, required this.categoryName});

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
          radius: 50,
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
          child: Column(
            children: [
              const SizedBox(height: 110),
              const Text(
                "Recherche d'un joueur",
                style: TextStyle(
                  fontFamily: 'Luckiest Guy',
                  fontSize: 30,
                  color: AppColors.background,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 5),

              Text(
                widget.categoryName,
                style: const TextStyle(
                  fontFamily: 'Luckiest Guy',
                  fontSize: 36,
                  color: AppColors.accent,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 1),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPlayer(username, pictureUrl),

                  const SizedBox(width: 40),

                  const Text(
                    'VS',
                    style: TextStyle(
                      fontFamily: 'Luckiest Guy',
                      fontSize: 44,
                      color: AppColors.background,
                    ),
                  ),

                  const SizedBox(width: 44),

                  Transform.translate(
                    offset: const Offset(0, -26), // Ajuste cette valeur si besoin
                    child: const SizedBox(
                      height: 90,
                      width: 90,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),

              const Spacer(flex: 1),

              Text(
                '$secondsLeft s',
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 30,
                  color: AppColors.background,
                ),
              ),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}
