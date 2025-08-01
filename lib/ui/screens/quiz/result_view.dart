import 'package:flutter/material.dart';
import '../../layout/special_layout.dart';

class ResultView extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultView({super.key, required this.resultData});

  String _getImageForScore(int score) {
    if (score <= 4) {
      return 'assets/images/himmel_lose.webp';
    } else if (score <= 7) {
      return 'assets/images/himmel_average.webp';
    } else {
      return 'assets/images/himmel_win.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scores = resultData['scores'] as Map<String, dynamic>?;
    final soloScore = resultData['score'] as int?;
    final totalQuestions = resultData['totalQuestions'] as int?;
    final players = resultData['players'] as List<dynamic>?;

    final scoreToUse = soloScore ?? (scores?.values.first as int?);
    final imagePath = scoreToUse != null ? _getImageForScore(scoreToUse) : null;

    return SpeLayout(
      child: Stack(
        children: [
          if (imagePath != null)
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          if ((players != null && players.isNotEmpty && totalQuestions != null))
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final username = player['username'] ?? 'Joueur';
                final image = player['image'] ?? '';
                final score = scores?[username] ?? soloScore ?? 0;
                final questions = player['questions'] as List<dynamic>? ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(image),
                      radius: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      username,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score / $totalQuestions',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ...questions.map((q) {
                      final question = q['question'] ?? 'Question inconnue';
                      final answer = q['answer'] ?? '---';
                      final correct = q['correct'] == true;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: correct ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          border: Border.all(color: correct ? Colors.green : Colors.red),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Réponse : $answer ${correct ? '✔️' : '❌'}',
                              style: const TextStyle(fontSize: 15, color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 30),
                  ],
                );
              },
            )
          else if (soloScore != null && totalQuestions != null)
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '$soloScore / $totalQuestions',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            )
          else
            const Center(
              child: Text('Score indisponible.', style: TextStyle(fontSize: 18)),
            ),
        ],
      ),
    );
  }
}