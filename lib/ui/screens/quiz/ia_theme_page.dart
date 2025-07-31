// import 'package:flutter/material.dart';
// import '../../../view_manager/ia_router.dart';
//
// class QuizIaThemePage extends StatelessWidget {
//   final String token;
//   const QuizIaThemePage({required this.token, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController controller = TextEditingController();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Saisis un thème')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Text('Quel thème veux-tu explorer ?'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: controller,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'Ex : mythologie, sport, cinéma...',
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 final theme = controller.text.trim();
//                 if (theme.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Veuillez entrer un thème.')),
//                   );
//                   return;
//                 }
//
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => IaRouter(
//                       token: token,
//                       theme: theme,
//                     ),
//                   ),
//                 );
//               },
//               child: const Text('Lancer le quiz'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import '../../../view_manager/ia_router.dart';
import '../../layout/special_layout.dart';


class QuizIaThemePage extends StatelessWidget {
  final String token;
  const QuizIaThemePage({required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return SpeLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // L'image au-dessus
            Image.asset(
              'assets/images/himmel_ia.png',
              height: 180,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 32),

            Text(
              'Quel thème veux-tu explorer ?',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex : mythologie, sport, cinéma...',
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                final theme = controller.text.trim();
                if (theme.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez entrer un thème.')),
                  );
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IaRouter(
                      token: token,
                      theme: theme,
                    ),
                  ),
                );
              },
              child: const Text('Lancer le quiz'),
            ),
          ],
        ),
      ),
    );
  }
}



