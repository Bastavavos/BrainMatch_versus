import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/user_provider.dart';
import '../../../view_manager/solo_router.dart';
import '../../../view_manager/versus_router.dart';

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
            alignment: Alignment.center,
            child: const Text(
              'Start',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}