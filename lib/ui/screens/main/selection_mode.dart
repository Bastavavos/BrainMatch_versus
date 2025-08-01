import 'package:brain_match/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/user_provider.dart';
import '../../widgets/arrow.dart';

class SelectionModePage extends ConsumerStatefulWidget {
  const SelectionModePage({super.key});

  @override
  ConsumerState<SelectionModePage> createState() => _SelectionModePageState();
}

class _SelectionModePageState extends ConsumerState<SelectionModePage>
    with TickerProviderStateMixin {
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
    ).animate(CurvedAnimation(parent: _imageController, curve: Curves.easeOut));

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

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

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.07),

              FadeTransition(
                opacity: _textOpacity,
                child: Center(
                  child: Text(
                    "Choisis un mode",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Luckiest Guy',
                      fontSize: 30.0,
                      color: colorScheme.primary
                    ),
                  ),
                ),
              ),

              Center(
                child: BouncingArrow(
                  size: 52,
                  duration: Duration(seconds: 1),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              _buildModeCard(
                context,
                title: "Versus",
                imagePath: 'assets/images/himmel_versus.png',
                color: colorScheme.primary,
                routeName: 'Versus',
                token: token,
                height: screenHeight * 0.13,
              ),

              SizedBox(height: screenHeight * 0.04),

              _buildModeCard(
                context,
                title: "Solo",
                imagePath: 'assets/images/himmel_solo_mode.png',
                color: colorScheme.secondary,
                routeName: 'Solo',
                token: token,
                height: screenHeight * 0.13,
              ),

              SizedBox(height: screenHeight * 0.04),

              _buildModeCard(
                context,
                title: "Créer ton quiz",
                imagePath: 'assets/images/himmel_2.png',
                color: colorScheme.tertiary,
                routeName: 'Ia',
                token: token,
                height: screenHeight * 0.13,
              ),

              SizedBox(height: screenHeight * 0.07),
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
        required double height,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token manquant, veuillez vous reconnecter'),
            ),
          );
          return;
        }
        Navigator.pushNamed(
          context,
          '/confirm',
          arguments: {'selectedMode': routeName, 'token': token},
        );
      },
      child: Container(
        height: height,
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Image alignée à gauche avec padding
            Positioned(
              left: 20,
              child: Image.asset(
                imagePath,
                height: 60,
                width: 60,
                fit: BoxFit.contain,
              ),
            ),

            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Luckiest Guy',
                  fontSize: 22.0,
                  color: title == "Solo" ? AppColors.primary : AppColors.light,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
