import 'package:flutter/material.dart';

class QuestionView extends StatelessWidget {
  final Map<String, dynamic> questionData;
  final int questionIndex;
  final int totalQuestions;
  final void Function(String answer) onAnswer;

  const QuestionView({
    super.key,
    required this.questionData,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final questionText = questionData['question'] ?? '';
    final options = List<String>.from(questionData['options'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${questionIndex + 1} / $totalQuestions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () => onAnswer(option),
                  child: Text(option),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
