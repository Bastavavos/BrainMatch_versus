import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../provider/background_music_provider.dart';
import '../../../provider/user_provider.dart';
import '../../widgets/button/form_button.dart';

/// Petit widget utilitaire pour appliquer l'effet "glass" autour d'un enfant.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Color? borderColor;
  final double blurSigma;
  final Color backgroundColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = const EdgeInsets.all(6),
    this.borderColor,
    this.blurSigma = 8.0,
    this.backgroundColor = const Color.fromRGBO(255, 255, 255, 0.06),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        borderColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.18);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(color: effectiveBorderColor, width: 1.0),
          ),
          child: child,
        ),
      ),
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // --- STOP MUSIQUE AU CHARGEMENT DE LA PAGE LOGIN ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final musicController = ref.read(backgroundMusicProvider.notifier);
      musicController.stop();
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = dotenv.env['API_KEY'];
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": _identifierController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await onLoginSuccess(data, ref); // token + appelle /me

        if (kDebugMode) {
          print("Connexion réussie avec token : ${data['token']}");
        }

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        setState(() {
          _errorMessage = data["message"] ?? "Erreur de connexion.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur de réseau : $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(BuildContext context, String label) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.6), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      filled: false, // important : on laisse GlassContainer gérer le background
    );
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --------- Fond plein écran (derrière tout, y compris status bar + bas) ----------
          Positioned.fill(
            child: Image.asset(
              'assets/images/fond-1.webp',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // léger overlay pour lisibilité (optionnel)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.08)),
          ),

          // --------- Contenu : formulaire centré (scrollable si clavier) ----------
          Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // centre verticalement
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      // logo supprimé (espace conservé)
                      const SizedBox(height: 40),

                      // Formulaire (inputs with glass)
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Identifiant
                            GlassContainer(
                              borderRadius: BorderRadius.circular(10),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              borderColor: primary.withOpacity(0.2),
                              blurSigma: 6.0,
                              backgroundColor: Colors.white.withOpacity(0.85), // <- blanc opaque
                              child: TextFormField(
                                controller: _identifierController,
                                textInputAction: TextInputAction.next,
                                decoration: _buildInputDecoration(context, 'Pseudo ou Email :'),
                                validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un email' : null,
                                style: TextStyle(color: primary), // <- texte primary
                              ),
                            ),


                            const SizedBox(height: 16),

                            // Mot de passe
                            GlassContainer(
                              borderRadius: BorderRadius.circular(10),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              borderColor: primary.withOpacity(0.2),
                              blurSigma: 6.0,
                              backgroundColor: Colors.white.withOpacity(0.85), // <- blanc opaque
                              child: TextFormField(
                                controller: _passwordController,
                                textInputAction: TextInputAction.next,
                                decoration: _buildInputDecoration(context, 'Pseudo ou Email :'),
                                validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un email' : null,
                                style: TextStyle(color: primary), // <- texte primary
                              ),
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.black), // <- noir
                          ),
                        ),

                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --------- Boutons ancrés en bas avec légère marge ----------
          Positioned(
            left: 0,
            right: 0,
            bottom: 12 + MediaQuery.of(context).padding.bottom, // marge légère + SafeArea
            child: SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FormButton(
                          label: _isLoading ? 'Connexion...' : 'Connexion',
                          icon: Icons.power_settings_new,
                          onPressed: _isLoading ? null : _login,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FormButton(
                          label: "Créer un compte",
                          icon: Icons.group_add,
                          onPressed: _isLoading ? null : () => Navigator.pushNamed(context, '/register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
