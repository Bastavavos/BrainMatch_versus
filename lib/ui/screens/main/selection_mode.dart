import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/user_provider.dart';

class SelectionModePage extends ConsumerStatefulWidget {
  const SelectionModePage({super.key});

  @override
  ConsumerState<SelectionModePage> createState() => _SelectionModePageState();
}

class _SelectionModePageState extends ConsumerState<SelectionModePage> with TickerProviderStateMixin {
  late AnimationController _imageController;
  late Animation<Offset> _imageOffsetAnimation;
  late AnimationController _textController;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _imageOffsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _imageController,
        curve: Curves.easeOut,
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _imageController.forward();
    _textController.forward();
  }

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(tokenProvider) ?? '';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // --- Animated Image ---
              SlideTransition(
                position: _imageOffsetAnimation,
                child: Center(
                  child: Image.asset(
                    'assets/images/himmel_2.png',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- Animated Text ---
              FadeTransition(
                opacity: _textOpacity,
                child: Center(
                  child: Text(
                    "Choisis ton mode de jeu",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 32),
              _buildModeCard(
                context,
                title: "Solo",
                imagePath: 'assets/images/himmel_solo_mode.png',
                color: colorScheme.primary,
                routeName: 'Solo',
                token: token,
              ),
              const SizedBox(height: 24),
              _buildModeCard(
                context,
                title: "Versus",
                imagePath: 'assets/images/himmel_versus.png',
                color: colorScheme.secondary,
                routeName: 'Versus',
                token: token,
              ),
              // const SizedBox(height: 24),
              // _buildModeCard(
              //   context,
              //   title: "Génère ton quiz",
              //   imagePath: 'assets/images/himmel_versus.png',
              //   color: colorScheme.secondary,
              //   routeName: 'Ia',
              //   token: token,
              // ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildModeCard(
      BuildContext context, {
        required String title,
        required String imagePath,
        required Color color,
        required String routeName,
        required String token,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token manquant, veuillez vous reconnecter')),
          );
          return;
        }
        Navigator.pushNamed(
          context,
          '/confirm',
          arguments: {
            'selectedMode': routeName,
            'token': token,
          },
        );
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 60,
              width: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}



