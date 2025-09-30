import 'package:flutter/material.dart';
import '../../theme.dart';

class ScoreProgressBar extends StatelessWidget {
  final int score;

  const ScoreProgressBar({
    Key? key,
    required this.score,
  }) : super(key: key);

  // Retourne l'image correspondant au palier
  Widget _getMilestoneImage(int milestone) {
    switch (milestone) {
      case 0:
        return Image.asset('assets/images/bronze_rank.png', width: 35, height: 35);
      case 50:
        return Image.asset('assets/images/plat_rank.png', width: 35, height: 35);
      case 100:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 150:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 200:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 250:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 300:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 350:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 400:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 450:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 500:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 550:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 600:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 650:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 700:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 750:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 800:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 850:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 900:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 950:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      case 1000:
        return Image.asset('assets/images/gold_rank.png', width: 35, height: 35);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentMilestone = (score ~/ 50) * 50;
    double progress = ((score - currentMilestone).clamp(0, 50)) / 50;

    // Limiter le palier pour ne pas dépasser 1000
    int nextMilestone = (currentMilestone + 50).clamp(0, 1000);
    int level = (score ~/ 50) + 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 350,
          child: Stack(
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: constraints.maxWidth * progress,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 350,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "$currentMilestone",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 1),
                  _getMilestoneImage(currentMilestone),
                ],
              ),
              // Texte au milieu
              Text(
                "Niveau : $level",
                style: const TextStyle(
                  fontSize: 24,
                  color: AppColors.primary,
                  fontFamily: 'Luckiest Guy',
                ),
              ),
              Column(
                children: [
                  Text(
                    "$nextMilestone",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  _getMilestoneImage(nextMilestone),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
