import 'package:brain_match/ui/layout/special_layout.dart';
import 'package:brain_match/ui/theme.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final questionText = questionData['question'] ?? '';
    final options = List<String>.from(questionData['options'] ?? []);
    final imageUrl = questionData['image'] != null
        ? formatImageUrl(questionData['image'])
        : null;

    return SpeLayout(
      child: Column(
        children: [
          if (imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 12.0), // léger padding top
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: AppColors.background, // utile si l’image est transparente
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain, // affiche toute l’image
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          Text(
            'Question ${questionIndex + 1} / $totalQuestions',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: timeLeft / 12000,
                backgroundColor: Colors.white,
                color: AppColors.primary,
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              questionText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Mulish',
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: options.map((option) {
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

                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: selectedAnswer == null ? () => onAnswer(option) : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(option, style: const TextStyle(fontSize: 16)),
                            ),
                            if (trailingIcon != null) trailingIcon,
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );

  }
}

