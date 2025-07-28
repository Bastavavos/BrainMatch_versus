import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brain_match/ui/layout/special_layout.dart';
import '../../../provider/user_provider.dart';
import '../../../view_manager/solo_router.dart';
import '../../../view_manager/versus_router.dart';

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryCard(context, colorScheme),
            const SizedBox(height: 30),
            _buildStartButton(context, ref, primaryColor),
            const SizedBox(height: 12),
            _buildBackButton(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black87, blurRadius: 8)],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref, Color buttonColor) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () => _handleStartPressed(context, ref),
        child: const Text('Start', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.outline,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text('Back to categories', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _handleStartPressed(BuildContext context, WidgetRef ref) {
    final token = ref.watch(tokenProvider);
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token invalide. Veuillez vous reconnecter.')),
      );
      return;
    }

    final Widget destination = mode == 'Solo'
        ? SoloRouter(categoryId: categoryId, token: token)
        : VersusRouter(categoryId: categoryId, token: token);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }
}
