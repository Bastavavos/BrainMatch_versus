import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brain_match/ui/layout/special_layout.dart';
import '../../widgets/button/start_button.dart';

class CategoryConfirmationPage extends ConsumerWidget {
  final String categoryId;
  final String title;
  final String description;
  final String imageUrl;
  final String logoUrl;
  final String mode;
  final String currentUser;

  const CategoryConfirmationPage({
    super.key,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.logoUrl,
    required this.mode,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = mode == 'Solo'
        ? colorScheme.primary
        : colorScheme.secondary;

    return SpeLayout(
      child: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundImage(), // l'image en fond
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                _buildTitle(context),
                const SizedBox(height: 20),
                _buildDescriptionCard(context, colorScheme),
                const Spacer(flex: 2),
                StartButton(
                  buttonColor: primaryColor,
                  mode: mode,
                  categoryId: categoryId,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        color: Colors.black.withOpacity(0.4),
        colorBlendMode: BlendMode.darken,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black87, blurRadius: 8)],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: colorScheme.surface.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}