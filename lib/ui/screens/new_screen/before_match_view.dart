import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme.dart';

class BeforeMatchView extends StatefulWidget {
  final Map<String, dynamic> opponent;
  final VoidCallback? onCountdownComplete;

  const BeforeMatchView({
    super.key,
    required this.opponent,
    this.onCountdownComplete,
  });

  @override
  State<BeforeMatchView> createState() => _BeforeMatchViewState();
}

class _BeforeMatchViewState extends State<BeforeMatchView>
    with SingleTickerProviderStateMixin {
  int _countdown = 3;
  late Timer _timer;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation =
        Tween<double>(begin: 1.5, end: 1.0).animate(CurvedAnimation(
          parent: _scaleController,
          curve: Curves.easeOut,
        ));

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_countdown > 0) {
          _countdown--;
          _scaleController.forward(from: 0);
        } else {
          timer.cancel();
          if (widget.onCountdownComplete != null) {
            widget.onCountdownComplete!();
          }
        }
      });
    });

    _scaleController.forward(from: 0);
  }

  @override
  void dispose() {
    _timer.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opponentName = widget.opponent['username'] ?? "Adversaire";
    final pictureUrl = widget.opponent['picture'];

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Adversaire trouvé !",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundImage:
              (pictureUrl != null && pictureUrl.isNotEmpty)
                  ? NetworkImage(pictureUrl)
                  : null,
              backgroundColor: AppColors.light,
              child: (pictureUrl == null || pictureUrl.isEmpty)
                  ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              opponentName,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Prépare-toi ! Le duel commence...",
              style: TextStyle(color: AppColors.secondaryAccent),
            ),
            const SizedBox(height: 32),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Text(
                _countdown > 0 ? '$_countdown' : 'GO !',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
