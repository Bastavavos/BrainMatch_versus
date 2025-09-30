// import 'package:brain_match/ui/layout/special_layout.dart';
// import 'package:brain_match/ui/theme.dart';
// import 'package:flutter/material.dart';
//
// class QuestionView extends StatefulWidget {
//   final Map<String, dynamic> questionData;
//   final int questionIndex;
//   final int totalQuestions;
//   final void Function(String answer) onAnswer;
//   final int timeLeft;
//   final String? selectedAnswer;
//   final String? correctAnswer;
//
//   const QuestionView({
//     super.key,
//     required this.questionData,
//     required this.questionIndex,
//     required this.totalQuestions,
//     required this.onAnswer,
//     required this.timeLeft,
//     this.selectedAnswer,
//     this.correctAnswer,
//   });
//
//   @override
//   State<QuestionView> createState() => _QuestionViewState();
// }
//
// class _QuestionViewState extends State<QuestionView> {
//   late List<String> shuffledOptions;
//
//   @override
//   void initState() {
//     super.initState();
//     shuffledOptions = List<String>.from(widget.questionData['options'] ?? []);
//     shuffledOptions.shuffle(); // Mélange pour la première question
//   }
//
//   @override
//   void didUpdateWidget(covariant QuestionView oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.questionData != widget.questionData) {
//       shuffledOptions = List<String>.from(widget.questionData['options'] ?? []);
//       shuffledOptions.shuffle(); // Mélange pour les questions suivantes
//     }
//   }
//
//   String formatImageUrl(String url) {
//     return url.replaceAll("localhost", "192.168.1.93");
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final questionText = widget.questionData['question'] ?? '';
//     final imageUrl = widget.questionData['image'] != null
//         ? formatImageUrl(widget.questionData['image'])
//         : null;
//
//     return SpeLayout(
//       titleWidget: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         decoration: BoxDecoration(
//           color: AppColors.primary,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Text(
//           'Question ${widget.questionIndex + 1} / ${widget.totalQuestions}',
//           style: const TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             fontFamily: 'Mulish',
//           ),
//         ),
//       ),
//       child: Column(
//         children: [
//           if (imageUrl != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
//               child: Container(
//                 width: double.infinity,
//                 height: MediaQuery.of(context).size.height * 0.25,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16.0),
//                   color: AppColors.background,
//                 ),
//                 clipBehavior: Clip.antiAlias,
//                 child: Image.network(
//                   imageUrl,
//                   fit: BoxFit.contain,
//                   alignment: Alignment.topCenter,
//                 ),
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: widget.timeLeft / 12000,
//                 backgroundColor: Colors.white,
//                 color: AppColors.primary,
//                 minHeight: 10,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               questionText,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontFamily: 'Mulish',
//                 color: AppColors.primary,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Column(
//               children: shuffledOptions.map((option) {
//                 final bool isSelected = widget.selectedAnswer == option;
//                 final bool isCorrect = widget.correctAnswer == option;
//
//                 Color borderColor = Colors.grey.shade300;
//                 Icon? trailingIcon;
//
//                 if (widget.selectedAnswer != null) {
//                   if (isSelected) {
//                     borderColor = isCorrect ? Colors.green : Colors.red;
//                     trailingIcon = Icon(
//                       isCorrect ? Icons.check_circle : Icons.cancel,
//                       color: isCorrect ? Colors.green : Colors.red,
//                     );
//                   } else if (isCorrect) {
//                     borderColor = Colors.green;
//                     trailingIcon = const Icon(
//                       Icons.check_circle,
//                       color: Colors.green,
//                     );
//                   }
//                 }
//
//                 return Container(
//                   margin: const EdgeInsets.symmetric(vertical: 6),
//                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: borderColor, width: 3),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: InkWell(
//                     onTap: widget.selectedAnswer == null
//                         ? () => widget.onAnswer(option)
//                         : null,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             option,
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                         if (trailingIcon != null) trailingIcon,
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//   }
// }
//
//
import 'package:brain_match/ui/layout/special_layout.dart';
import 'package:brain_match/ui/theme.dart';
import 'package:flutter/material.dart';

class QuestionView extends StatefulWidget {
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

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  late List<String> shuffledOptions;
  String? selectedAnswerLocal;

  @override
  void initState() {
    super.initState();
    _prepareOptions();
  }

  @override
  void didUpdateWidget(covariant QuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionData != widget.questionData) {
      _prepareOptions();
    }
  }

  void _prepareOptions() {
    shuffledOptions = List<String>.from(widget.questionData['options'] ?? []);
    shuffledOptions.shuffle();
    selectedAnswerLocal = null;
  }

  String formatImageUrl(String url) {
    return url.replaceAll("localhost", "192.168.1.93");
  }

  @override
  Widget build(BuildContext context) {
    final questionText = widget.questionData['question'] ?? '';
    final imageUrl = widget.questionData['image'] != null
        ? formatImageUrl(widget.questionData['image'])
        : null;

    return SpeLayout(
      titleWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'Question ${widget.questionIndex + 1} / ${widget.totalQuestions}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Mulish',
          ),
        ),
      ),
      child: Column(
        children: [
          if (imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: AppColors.background,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: widget.timeLeft / 12000,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: shuffledOptions.map((option) {
                final bool isSelected = selectedAnswerLocal == option;
                final bool isCorrect = widget.correctAnswer == option;

                Color borderColor = Colors.grey.shade300;
                Icon? trailingIcon;

                if (selectedAnswerLocal != null) {
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

                return Container(
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
                    onTap: selectedAnswerLocal == null
                        ? () {
                      setState(() {
                        selectedAnswerLocal = option;
                      });
                      widget.onAnswer(option);
                    }
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}


