import 'package:flutter/material.dart';

class QuestionView extends StatelessWidget {
  final Map<String, dynamic> questionData;
  final int questionIndex;
  final int totalQuestions;
  final void Function(String answer) onAnswer;
  final int timeLeft;
  final String? selectedAnswer;
  final String? correctAnswer;

  const QuestionView({
    super.key,
    required this.questionData,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onAnswer,
    required this.timeLeft,
    this.selectedAnswer,
    this.correctAnswer,
  });

  String formatImageUrl(String url) {
    return url.replaceAll("localhost", "192.168.1.74");
    // return url.replaceAll("localhost", "192.168.1.17");
  }

  @override
  Widget build(BuildContext context) {
    final questionText = questionData['question'] ?? '';
    final options = List<String>.from(questionData['options'] ?? []);
    final imageUrl = questionData['image'] != null
        ? formatImageUrl(questionData['image'])
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${questionIndex + 1} / $totalQuestions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: timeLeft / 100,
                backgroundColor: Colors.grey[300],
                color: Colors.deepPurple,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),
            ...options.map((option) {
              final bool isSelected = selectedAnswer == option;
              final bool isCorrect = correctAnswer == option;

              Color borderColor = Colors.grey.shade300;
              Icon? trailingIcon;

              if (selectedAnswer != null) {
                if (isSelected) {
                  borderColor = isCorrect ? Colors.green : Colors.red;
                  trailingIcon = Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                  );
                } else if (isCorrect) {
                  borderColor = Colors.green;
                  trailingIcon = const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  );
                }
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: selectedAnswer == null ? () => onAnswer(option) : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(option, style: const TextStyle(fontSize: 18))),
                      if (trailingIcon != null) trailingIcon,
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
