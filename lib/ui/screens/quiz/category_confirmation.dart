import 'package:brain_match/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brain_match/ui/layout/special_layout.dart';
import '../../theme.dart';
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
      child: Stack(
        fit: StackFit.expand, // ← étend le Stack à toute la taille disponible
        children: [
          _buildBackgroundImage(),

          Container(color: Colors.black.withOpacity(0.4)), // overlay assombrissant

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(), // pousse le titre+description vers le centre verticalement

                  // Titre en haut
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      shadows: const [Shadow(color: Colors.black87, blurRadius: 8)],
                      fontSize: 36,
                      fontFamily: 'Luckiest Guy',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description juste en dessous du titre
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Luckiest Guy',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(), // pousse le bouton vers le bas

                  // Bouton en bas
                  StartButton(
                    buttonColor: primaryColor,
                    mode: mode,
                    categoryId: categoryId,
                  ),

                  const SizedBox(height: 40), // marge sous le bouton
                ],
              ),

            ),
          ),

        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Luckiest Guy',
          color: AppColors.accent,
          fontSize: 50,
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
            style: TextStyle(
              fontFamily: 'Mulish',
              color: AppColors.primary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
