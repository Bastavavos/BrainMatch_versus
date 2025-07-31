import 'package:flutter/material.dart';
import 'dart:math';

class WavyText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color? color;

  const WavyText(this.text, {super.key, this.style, this.color});

  @override
  State<WavyText> createState() => _WavyTextState();
}

class _WavyTextState extends State<WavyText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // boucle infinie
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text.characters.toList(); // supporte accents/emojis

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(text.length, (i) {
            // Décalage de phase par lettre
            final double offset = sin((_controller.value * 2 * pi) + (i * 0.3)) * 8;

            return Transform.translate(
              offset: Offset(0, offset),
              child: Text(
                text[i],
                style: widget.style?.copyWith(color: widget.color) ??
                    Theme.of(context).textTheme.titleLarge,
              ),
            );
          }),
        );
      },
    );
  }
}
