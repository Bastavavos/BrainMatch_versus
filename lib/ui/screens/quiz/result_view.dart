import 'package:flutter/material.dart';
import '../../layout/special_layout.dart';

class ResultView extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultView({super.key, required this.resultData});

  String _getImageForScore(int score) {
    if (score <= 4) {
      return 'assets/images/himmel_lose.png';
    } else if (score <= 7) {
      return 'assets/images/himmel_average.png';
    } else {
      return 'assets/images/himmel_win.png';
    }
  }

  Widget buildCenteredResult({
    required int score,
    required int totalQuestions,
    String? playerName,
  }) {
    return Stack(
      children: [
        // Image de fond avec assombrissement
        Positioned.fill(
          child: Image.asset(
            _getImageForScore(score),
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5), // filtre sombre
            colorBlendMode: BlendMode.darken,
          ),
        ),
        // Contenu principal
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (playerName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    playerName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // texte lisible
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Score : $score / $totalQuestions',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // texte lisible
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 4,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scores = resultData['scores'] as Map<String, dynamic>?;
    final soloScore = resultData['score'] as int?;
    final totalQuestions = resultData['totalQuestions'] as int?;

    return SpeLayout(
      child: (scores != null && totalQuestions != null)
          ? ListView(
        padding: const EdgeInsets.all(0),
        children: scores.entries.map((entry) {
          final playerName = entry.key;
          final playerScore = entry.value as int;
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: buildCenteredResult(
              score: playerScore,
              totalQuestions: totalQuestions,
              playerName: playerName,
            ),
          );
        }).toList(),
      )
          : (soloScore != null && totalQuestions != null)
          ? SizedBox.expand(
        child: buildCenteredResult(
          score: soloScore,
          totalQuestions: totalQuestions,
        ),
      )
          : const Center(
        child: Text(
          'Score indisponible.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
