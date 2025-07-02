import 'package:flutter/material.dart';
import '../../layout/special_layout.dart';

class QuizResultPage extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final String mode;

  const QuizResultPage({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final double scorePercent = correctAnswers / totalQuestions;
    final bool isSolo = mode == 'Solo';
    final Color primaryColor = isSolo ? Colors.deepPurple : Colors.redAccent;

    return SpeLayout(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                scorePercent >= 0.8
                    ? Icons.emoji_events
                    : scorePercent >= 0.5
                    ? Icons.thumb_up
                    : Icons.school,
                size: 100,
                color: primaryColor,
              ),
              const SizedBox(height: 32),
              Text(
                'Quiz terminé !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu as obtenu',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                '$correctAnswers / $totalQuestions',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              LinearProgressIndicator(
                value: scorePercent,
                backgroundColor: Colors.grey.shade200,
                color: primaryColor,
                minHeight: 10,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                icon: const Icon(Icons.replay),
                label: const Text(
                  'Recommencer',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
//
// class QuizResultPage extends StatelessWidget {
//   final int totalQuestions;
//   final int correctAnswers;
//   final String mode;
//
//   const QuizResultPage({
//     super.key,
//     required this.totalQuestions,
//     required this.correctAnswers,
//     required this.mode,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final double scorePercent = correctAnswers / totalQuestions;
//     final bool isSolo = mode == 'Solo';
//     final Color primaryColor = isSolo ? Colors.deepPurple : Colors.redAccent;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 scorePercent >= 0.8
//                     ? Icons.emoji_events
//                     : scorePercent >= 0.5
//                     ? Icons.thumb_up
//                     : Icons.school,
//                 size: 100,
//                 color: primaryColor,
//               ),
//               const SizedBox(height: 32),
//               Text(
//                 'Quiz terminé !',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Tu as obtenu',
//                 style: TextStyle(fontSize: 20),
//               ),
//               Text(
//                 '$correctAnswers / $totalQuestions',
//                 style: TextStyle(
//                   fontSize: 36,
//                   fontWeight: FontWeight.bold,
//                   color: primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 32),
//               LinearProgressIndicator(
//                 value: scorePercent,
//                 backgroundColor: Colors.grey.shade200,
//                 color: primaryColor,
//                 minHeight: 10,
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton.icon(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 24, vertical: 14),
//                 ),
//                 icon: const Icon(Icons.replay),
//                 label: const Text(
//                   'Recommencer',
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
