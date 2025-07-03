import 'package:flutter/material.dart';
import 'package:brain_match/ui/screens/quiz/quiz_question.dart';
import 'package:brain_match/ui/layout/special_layout.dart';
import '../../../resources/socket_client.dart';

class CategoryConfirmationPage extends StatelessWidget {
  final String categoryId;
  final String title;
  final String description;
  final String imageUrl;
  final String logoUrl;
  final String mode;
  final String currentUser;
  final String token;

  const CategoryConfirmationPage({
    super.key,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.logoUrl,
    required this.mode,
    required this.currentUser,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = mode == 'Solo' ? colorScheme.primary : colorScheme.secondary;

    return SpeLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryCard(context, colorScheme),
            const SizedBox(height: 30),
            _buildStartButton(context, primaryColor),
            const SizedBox(height: 12),
            _buildBackButton(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black87, blurRadius: 8)],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Card(
                color: colorScheme.surface.withOpacity(0.9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, Color buttonColor) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () => _handleStartPressed(context),
        child: const Text('Start', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.outline,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text('Back to categories', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _handleStartPressed(BuildContext context) {
    if (token.isEmpty || token.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token invalide. Veuillez vous reconnecter.')),
      );
      return;
    }

    if (mode == 'Solo') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizPlayPage(
            categoryId: categoryId,
            mode: mode,
            currentUser: currentUser,
            token: token,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          title: Text('En attente d’un autre joueur...'),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Recherche en cours...')),
            ],
          ),
        ),
      );

      SocketClient().connect(
        token: token,
        categoryId: categoryId,
        currentUser: currentUser,
        onStartGame: (data) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuizPlayPage(
                categoryId: categoryId,
                mode: mode,
                versusData: data,
                currentUser: currentUser,
                token: token,
              ),
            ),
          );
        },
        onQuestionResult: (result) {
          print('📊 Résultat question reçu : $result');
        },
        onError: (message) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $message')),
          );
        },
      );
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:brain_match/ui/screens/quiz/quiz_question.dart';
// import 'package:brain_match/ui/layout/special_layout.dart';
//
// import '../../../resources/socket_client.dart';
//
// class CategoryConfirmationPage extends StatelessWidget {
//   final String categoryId;
//   final String title;
//   final String description;
//   final String imageUrl;
//   final String logoUrl;
//   final String mode;
//   final String currentUser;
//   final String token;
//
//   const CategoryConfirmationPage({
//     super.key,
//     required this.categoryId,
//     required this.title,
//     required this.description,
//     required this.imageUrl,
//     required this.logoUrl,
//     required this.mode,
//     required this.currentUser,
//     required this.token,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final primaryColor = mode == 'Solo' ? colorScheme.primary : colorScheme.secondary;
//
//     return SpeLayout(
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                 clipBehavior: Clip.antiAlias,
//                 child: Container(
//                   width: double.infinity,
//                   height: 500,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: NetworkImage(imageUrl),
//                       fit: BoxFit.cover,
//                       colorFilter: ColorFilter.mode(
//                         Colors.black.withOpacity(0.4),
//                         BlendMode.darken,
//                       ),
//                     ),
//                   ),
//                   child: Stack(
//                     children: [
//                       Center(
//                         child: Text(
//                           title,
//                           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             shadows: const [
//                               Shadow(color: Colors.black87, blurRadius: 8),
//                             ],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 24,
//                         left: 20,
//                         right: 20,
//                         child: Card(
//                           color: colorScheme.surface.withOpacity(0.9),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                           elevation: 3,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Text(
//                               description,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: 250,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   onPressed: () {
//                     if (mode == 'Solo') {
//                       // Solo mode - navigation directe
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => QuizPlayPage(
//                             categoryId: categoryId,
//                             mode: mode,
//                             currentUser: currentUser,
//                             token: token,
//                           ),
//                         ),
//                       );
//                     } else {
//                       // Versus mode - connexion socket
//                       final username = 'username'; // TODO: remplacer par le vrai pseudo
//
//                       showDialog(
//                         context: context,
//                         barrierDismissible: false,
//                         builder: (_) => AlertDialog(
//                           title: const Text('En attente d’un autre joueur...'),
//                           content: Row(
//                             children: const [
//                               CircularProgressIndicator(),
//                               SizedBox(width: 20),
//                               Expanded(child: Text('Recherche en cours...')),
//                             ],
//                           ),
//                         ),
//                       );
//
//                       SocketClient().connect(
//                         username: currentUser,
//                         categoryId: categoryId,
//                         currentUser: currentUser,
//                         token: token,
//                         onStartGame: (data) {
//                           Navigator.pop(context); // Fermer le dialog d’attente
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => QuizPlayPage(
//                                 categoryId: categoryId,
//                                 mode: mode,
//                                 versusData: data,
//                                 currentUser: currentUser,
//                                 token: token,
//                               ),
//                             ),
//                           );
//                         },
//                         onQuestionResult: (result) {
//                           // Gérer les résultats de la question
//                           print('📊 Résultat question reçu : $result');
//                         },
//                         onError: (message) {
//                           Navigator.pop(context); // Fermer le dialog
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Erreur : $message')),
//                           );
//                         },
//                       );
//                     }
//                   },
//                   child: const Text('Start', style: TextStyle(fontSize: 18)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 width: 250,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: colorScheme.outline,
//                     foregroundColor: colorScheme.onSurface,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text(
//                     'Back to categories',
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }