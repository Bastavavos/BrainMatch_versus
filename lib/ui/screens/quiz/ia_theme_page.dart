import 'package:flutter/material.dart';

import '../../../view_manager/ia_router.dart';
//
//
// class QuizIaThemePage extends StatefulWidget {
//   const QuizIaThemePage({super.key});
//
//   @override
//   State<QuizIaThemePage> createState() => _QuizIaThemePageState();
// }
//
// class _QuizIaThemePageState extends State<QuizIaThemePage> {
//   final TextEditingController _controller = TextEditingController();
//   final bool _isLoading = false;
//   String? token;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//     token = args?['token'];
//   }
//
//   void _startQuiz() {
//     final theme = _controller.text.trim();
//
//     if (theme.isEmpty || token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Veuillez entrer un thème valide.')),
//       );
//       return;
//     }
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => IaRouter(token: token!, theme: theme),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Thème du quiz IA'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               "Entre un thème pour générer ton quiz IA :",
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText: "Ex : histoire, cinéma, animaux...",
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _startQuiz,
//               child: const Text("Lancer le quiz"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class QuizIaThemePage extends StatelessWidget {
  final String token;
  const QuizIaThemePage({required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Saisis un thème')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Quel thème veux-tu explorer ?'),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex : mythologie, sport, cinéma...',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final theme = _controller.text.trim();
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

