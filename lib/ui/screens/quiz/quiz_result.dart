import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final String mode;
  final Map<String, dynamic>? versusData;
  final bool opponentDisconnected;

  const QuizResultPage({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.mode,
    this.versusData,
    this.opponentDisconnected = false,
  });

  @override
  Widget build(BuildContext context) {
    String message = "Vous avez terminé le quiz en mode ${mode == 'Solo' ? 'Solo' : 'Versus'}!";
    if (mode == 'Versus' && opponentDisconnected) {
      message = "Votre adversaire s'est déconnecté. Voici votre score.";
    } else if (mode == 'Versus' && versusData != null) {
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats du Quiz'),
        automaticallyImplyLeading: false,
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
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}