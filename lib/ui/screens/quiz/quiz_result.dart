// Dans lib/ui/screens/quiz/quiz_result.dart (APRÈS la modification)
import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final String mode;
  final Map<String, dynamic>? versusData; // Ajoutez ce paramètre
  final bool opponentDisconnected;     // Ajoutez ce paramètre

  const QuizResultPage({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.mode,
    this.versusData,                // Rendez-le optionnel si ce n'est pas toujours fourni
    this.opponentDisconnected = false, // Valeur par défaut si non fourni
  });

  @override
  Widget build(BuildContext context) {
    // Vous pouvez maintenant utiliser this.versusData et this.opponentDisconnected ici
    // par exemple pour afficher des messages différents ou des informations supplémentaires.

    String message = "Vous avez terminé le quiz en mode ${mode == 'Solo' ? 'Solo' : 'Versus'}!";
    if (mode == 'Versus' && opponentDisconnected) {
      message = "Votre adversaire s'est déconnecté. Voici votre score.";
    } else if (mode == 'Versus' && versusData != null) {
      // Vous pourriez vouloir afficher les noms des joueurs ou d'autres infos de versusData
      // final players = versusData!['players'] as List<dynamic>;
      // final localPlayerId = versusData!['localPlayerId']; // Assurez-vous d'avoir cette info
      // final localPlayerUsername = players.firstWhere((p) => p['id'] == localPlayerId)['username'];
      // message = "Fin de la partie Versus, $localPlayerUsername !";
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats du Quiz'),
        automaticallyImplyLeading: false, // Empêche le bouton retour si vous voulez
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              message,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Votre Score: $correctAnswers / $totalQuestions',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers l'écran d'accueil ou un autre écran approprié
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Ou si vous avez une route nommée pour l'accueil :
                // Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              child: Text('Retour à l\'accueil'),
            ),
            // Vous pourriez vouloir afficher plus de détails si c'est un mode Versus
            // if (mode == 'Versus' && versusData != null && !opponentDisconnected) ...
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import '../../layout/special_layout.dart';
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
//     return SpeLayout(
//       child: Center(
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
//               const Text(
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
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
//
//
//
// // import 'package:flutter/material.dart';
// //
// // class QuizResultPage extends StatelessWidget {
// //   final int totalQuestions;
// //   final int correctAnswers;
// //   final String mode;
// //
// //   const QuizResultPage({
// //     super.key,
// //     required this.totalQuestions,
// //     required this.correctAnswers,
// //     required this.mode,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final double scorePercent = correctAnswers / totalQuestions;
// //     final bool isSolo = mode == 'Solo';
// //     final Color primaryColor = isSolo ? Colors.deepPurple : Colors.redAccent;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(24.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(
// //                 scorePercent >= 0.8
// //                     ? Icons.emoji_events
// //                     : scorePercent >= 0.5
// //                     ? Icons.thumb_up
// //                     : Icons.school,
// //                 size: 100,
// //                 color: primaryColor,
// //               ),
// //               const SizedBox(height: 32),
// //               Text(
// //                 'Quiz terminé !',
// //                 style: TextStyle(
// //                   fontSize: 28,
// //                   fontWeight: FontWeight.bold,
// //                   color: primaryColor,
// //                 ),
// //               ),
// //               const SizedBox(height: 16),
// //               Text(
// //                 'Tu as obtenu',
// //                 style: TextStyle(fontSize: 20),
// //               ),
// //               Text(
// //                 '$correctAnswers / $totalQuestions',
// //                 style: TextStyle(
// //                   fontSize: 36,
// //                   fontWeight: FontWeight.bold,
// //                   color: primaryColor,
// //                 ),
// //               ),
// //               const SizedBox(height: 32),
// //               LinearProgressIndicator(
// //                 value: scorePercent,
// //                 backgroundColor: Colors.grey.shade200,
// //                 color: primaryColor,
// //                 minHeight: 10,
// //               ),
// //               const SizedBox(height: 32),
// //               ElevatedButton.icon(
// //                 onPressed: () => Navigator.pop(context),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: primaryColor,
// //                   padding: const EdgeInsets.symmetric(
// //                       horizontal: 24, vertical: 14),
// //                 ),
// //                 icon: const Icon(Icons.replay),
// //                 label: const Text(
// //                   'Recommencer',
// //                   style: TextStyle(fontSize: 16, color: Colors.white),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
