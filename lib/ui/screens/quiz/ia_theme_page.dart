import 'package:flutter/material.dart';
import '../../../view_manager/ia_router.dart';
import '../../layout/special_layout.dart';


class QuizIaThemePage extends StatefulWidget {
  final String token;
  const QuizIaThemePage({required this.token, super.key});

  @override
  State<QuizIaThemePage> createState() => _QuizIaThemePageState();
}

class _QuizIaThemePageState extends State<QuizIaThemePage> {
  final TextEditingController controller = TextEditingController();
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  void _handlePressed() {
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
          token: widget.token,
          theme: theme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SpeLayout(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/himmel_ia.png',
            fit: BoxFit.cover,
          ),

          Container(color: Colors.black.withOpacity(0.5)),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 48),
                          Text(
                            'Quel thème veux-tu explorer ?',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: controller,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20
                            ),
                            decoration: InputDecoration(
                              hintText: 'Ex : mythologie, sport, cinéma...',
                              hintStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  AnimatedScale(
                    scale: _scale,
                    duration: const Duration(milliseconds: 100),
                    child: GestureDetector(
                      onTapDown: _onTapDown,
                      onTapUp: _onTapUp,
                      onTapCancel: _onTapCancel,
                      onTap: _handlePressed,
                      child: Container(
                        width: 280,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Lancer le quiz',
                          style: TextStyle(
                            fontFamily: 'Luckiest Guy',
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}