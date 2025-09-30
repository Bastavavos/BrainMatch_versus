import 'package:flutter/material.dart';
import '../../layout/special_layout.dart';

class ResultView extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultView({super.key, required this.resultData});

  String _getImageForScore(int score) {
    if (score <= 4) return 'assets/images/himmel_lose.webp';
    if (score <= 7) return 'assets/images/himmel_average.webp';
    return 'assets/images/himmel_win.png';
  }

  Widget buildPlayerCard(Map<String, dynamic> player, int totalQuestions) {
    final username = player['username'] ?? 'Joueur';
    final image = player['image'] ?? '';
    final score = player['score'] ?? 0;

    return Column(
      children: [
        CircleAvatar(
          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
          radius: 40,
          child: image.isEmpty ? const Icon(Icons.person, size: 40) : null,
        ),
        const SizedBox(height: 8),
        Text(
          username,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          '$score / $totalQuestions',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  Widget buildQuestionHistory(List<dynamic>? questions) {
    if (questions == null || questions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: questions.map((q) {
        final qMap = q as Map<String, dynamic>;

        final questionText = (qMap['question'] is String)
            ? qMap['question']
            : (qMap['question']?['question'] ?? 'Question inconnue');

        final answer = qMap['answer'] ?? '---';
        final correct = qMap['correct'] == true;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: correct
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            border: Border.all(color: correct ? Colors.green : Colors.red),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                questionText,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Réponse : $answer ${correct ? "(✓)" : "(✗)"}',
                style: const TextStyle(fontSize: 15, color: Colors.white70),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int? soloScore = resultData['score'] as int?;
    final int? totalQuestions = resultData['totalQuestions'] as int?;
    final List<dynamic>? players = resultData['players'] as List<dynamic>?;

    // Normalisation : VersusRouter envoie players = [currentPlayer, opponentPlayer]
    final List<Map<String, dynamic>> normalizedPlayers = (players ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final bool isVersus = normalizedPlayers.length >= 2;

    // Image de fond : dépend de ton score si dispo
    final int scoreForBackground = soloScore ??
        (normalizedPlayers.isNotEmpty
            ? (normalizedPlayers.first['score'] ?? 0)
            : 0);
    final imagePath = _getImageForScore(scoreForBackground);

    return SpeLayout(
      child: Stack(
        children: [
          if (imagePath.isNotEmpty)
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
              ),
            ),

          if (totalQuestions != null)
            ListView(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              children: [
                // Mode SOLO / IA -> juste ton score
                if (!isVersus && soloScore != null)
                  Center(
                    child: Text(
                      '$soloScore / $totalQuestions',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                // Mode VERSUS -> les 2 joueurs affichés en haut
                if (isVersus) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: normalizedPlayers
                        .map((p) => buildPlayerCard(p, totalQuestions))
                        .toList(),
                  ),
                  const SizedBox(height: 30),
                ],

                // Historique de ton joueur courant (toujours premier dans la liste)
                buildQuestionHistory(
                  (normalizedPlayers.isNotEmpty
                      ? normalizedPlayers.first['questions']
                      : null)
                  as List<dynamic>?,
                ),
              ],
            )
          else
            const Center(
              child: Text('Score indisponible.',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
