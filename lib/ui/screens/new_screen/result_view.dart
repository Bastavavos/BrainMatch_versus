import 'package:flutter/material.dart';

class ResultView extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultView({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final scores = resultData['scores'] as Map<String, dynamic>?;
    final soloScore = resultData['score'];
    final totalQuestions = resultData['totalQuestions'];

    return Scaffold(
      appBar: AppBar(title: const Text("Résultat")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: scores != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: scores.entries.map((entry) {
            return Text(
              '${entry.key} : ${entry.value} / $totalQuestions',
              style: const TextStyle(fontSize: 20),
            );
          }).toList(),
        )
            : soloScore != null && totalQuestions != null
            ? Center(
          child: Text(
            'Score : $soloScore / $totalQuestions',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : const Text('Score indisponible.'),
      ),
    );
  }
}

