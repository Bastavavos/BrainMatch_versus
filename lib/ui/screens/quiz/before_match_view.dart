import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/user_provider.dart';
import '../../../service/api_service.dart';
import '../../layout/special_layout.dart';
import '../../theme.dart';

class BeforeMatchView extends ConsumerStatefulWidget {
  final Map<String, dynamic> opponent;

  const BeforeMatchView({super.key, required this.opponent});

  @override
  ConsumerState<BeforeMatchView> createState() => _BeforeMatchViewState();
}

class _BeforeMatchViewState extends ConsumerState<BeforeMatchView>
    with SingleTickerProviderStateMixin {
  int countdown = 3;
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late String? opponentPicture;


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

    final String? picturePath = widget.opponent['picture'];
    opponentPicture = (picturePath != null && picturePath.isNotEmpty)
        ? Uri.parse(ApiService.baseUrl).resolve(picturePath).toString()
        : null;


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
    final String userName = user?.username ?? 'Anonyme';
    final String? userPicture = user?.picture;
    final String opponentName = widget.opponent['username'] ?? "Adversaire";

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;

    return SpeLayout(
      child: Container(
        color: AppColors.primary,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 110),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Adversaire trouvé !",
                  style: TextStyle(
                    fontFamily: 'Luckiest Guy',
                    fontSize: isSmallScreen ? 24 : 30,
                    color: AppColors.background,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 1),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _buildPlayer(userName, userPicture),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'VS',
                      style: TextStyle(
                        fontFamily: 'Luckiest Guy',
                        fontSize: 40,
                        color: AppColors.background,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildPlayer(opponentName, opponentPicture),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Text(
                      '$countdown',
                      style: TextStyle(
                        fontFamily: 'Luckiest Guy',
                        fontSize: isSmallScreen ? 48 : 64,
                        color: AppColors.accent,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}
