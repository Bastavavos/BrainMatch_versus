import 'package:flutter/material.dart';

import '../../layout/special_layout.dart';
import '../../theme.dart';

class LoadingContent extends StatelessWidget {
  const LoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SpeLayout(
      child: SizedBox(
        height: screenHeight,
        width: double.infinity,
        child: Stack(
          children: [
            // Image de fond pleine page
            Positioned.fill(
              child: Image.asset(
                'assets/images/himmel_ia.png',
                fit: BoxFit.cover,
              ),
            ),

            // Loader et texte : en haut, mais centré horizontalement
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Chargement en cours...',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Luckiest Guy',
                          color: AppColors.background,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
