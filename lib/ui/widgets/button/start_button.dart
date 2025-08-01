import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/user_provider.dart';
import '../../../view_manager/solo_router.dart';
import '../../../view_manager/versus_router.dart';
import '../../theme.dart';

class StartButton extends ConsumerStatefulWidget {
  final Color buttonColor;
  final String mode;
  final String categoryId;

  const StartButton({
    super.key,
    required this.buttonColor,
    required this.mode,
    required this.categoryId,
  });

  @override
  ConsumerState<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends ConsumerState<StartButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  void _handleStartPressed(BuildContext context) {
    final token = ref.watch(tokenProvider);
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token invalide. Veuillez vous reconnecter.')),
      );
      return;
    }

    final Widget destination = widget.mode == 'Solo'
        ? SoloRouter(categoryId: widget.categoryId, token: token)
        : VersusRouter(categoryId: widget.categoryId, token: token);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.mode == 'Versus'
        ? AppColors.primary // ou une autre couleur si tu veux le texte en AppColors.primary
        : AppColors.light;
    return Center(
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: () => _handleStartPressed(context),
          child: Container(
            width: 280,
            height: 60,
            decoration: BoxDecoration(
              color: widget.buttonColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),

            child: Center(
              child: SizedBox(
                height: 30, // hauteur approximative du texte
                child: Baseline(
                  baseline: 24, // ← ajuste selon ta police (25 - 26 = bon pour fontSize 25)
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    'Start',
                    style: TextStyle(
                      fontFamily: 'Luckiest Guy',
                      color: textColor,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}