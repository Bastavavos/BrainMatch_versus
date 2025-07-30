import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const FormButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: onPressed == null ? 1.0 : 1.0, // pourra être utilisé avec animation plus tard
        child: SizedBox(
          width: 240, // plus large
          height: 60,  // plus haut
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, // fond foncé
              foregroundColor: Colors.white, // icône en blanc
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // plus carré
              ),
              elevation: 5,
              shadowColor: colorScheme.primary.withOpacity(0.4),
            ),
            icon: Icon(icon, size: 20, color: Colors.white),
            label: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
