import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../service/api_service.dart';
import '../../theme.dart';

class BeforeMatchView extends StatefulWidget {
  final Map<String, dynamic> opponent;

  const BeforeMatchView({
    super.key,
    required this.opponent,
  });

  @override
  State<BeforeMatchView> createState() => _BeforeMatchViewState();
}

class _BeforeMatchViewState extends State<BeforeMatchView>
    with SingleTickerProviderStateMixin {
  int countdown = 3;
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 1) {
        timer.cancel();
        return;
      }

      setState(() {
        countdown--;
      });

      _animationController.forward(from: 0.0);
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opponentName = widget.opponent['username'] ?? "Adversaire";
    final picturePath = widget.opponent['picture'] as String?;

    final String? imageUrl = (picturePath != null && picturePath.isNotEmpty)
        ? Uri.parse(ApiService.baseUrl)
        .resolve('$picturePath?cb=${DateTime.now().millisecondsSinceEpoch}')
        .toString()
        : null;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Adversaire trouvé !",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Avatar avec fallback
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.light,
                backgroundImage: imageUrl != null
                    ? CachedNetworkImageProvider(imageUrl)
                    : null,
                child: imageUrl == null
                    ? Text(
                  opponentName.isNotEmpty
                      ? opponentName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 30,
                    color: AppColors.primary,
                  ),
                )
                    : null,
              ),

              const SizedBox(height: 12),
              Text(
                opponentName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Prépare-toi au duel !",
                style: TextStyle(
                  color: AppColors.secondaryAccent,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 48),

              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Text(
                      '$countdown',
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
