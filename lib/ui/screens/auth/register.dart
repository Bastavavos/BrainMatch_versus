import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../provider/user_provider.dart';
import '../../widgets/button/form_button.dart';

/// On réutilise le même GlassContainer que dans LoginPage
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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = dotenv.env['API_KEY'];
      final registerResponse = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      if (registerResponse.statusCode == 201) {
        final loginResponse = await http.post(
          Uri.parse("$baseUrl/login"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "identifier": _emailController.text.trim(),
            "password": _passwordController.text.trim(),
          }),
        );

        final loginData = jsonDecode(loginResponse.body);

        if (loginResponse.statusCode == 200) {
          if (!mounted) return;
          await onLoginSuccess(loginData, ref);
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          setState(() {
            _errorMessage =
                loginData['message'] ?? 'Échec de la connexion après inscription.';
          });
        }
      } else {
        final data = jsonDecode(registerResponse.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Échec de l’inscription.';
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --------- Fond plein écran ----------
          Positioned.fill(
            child: Image.asset(
              'assets/images/fond-2.webp',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // overlay pour lisibilité
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.08)),
          ),

          // --------- Contenu centré ----------
          Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const SizedBox(height: 40),

                      // --------- Formulaire ---------
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Username
                            GlassContainer(
                              borderRadius: BorderRadius.circular(10),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              borderColor: primary.withOpacity(0.2),
                              blurSigma: 6.0,
                              backgroundColor: Colors.white.withOpacity(0.85),
                              child: TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: _buildInputDecoration(context, 'Nom :'),
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Veuillez entrer un nom'
                                    : null,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Email
                            GlassContainer(
                              borderRadius: BorderRadius.circular(10),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              borderColor: primary.withOpacity(0.2),
                              blurSigma: 6.0,
                              backgroundColor: Colors.white.withOpacity(0.85),
                              child: TextFormField(
                                controller: _emailController,
                                textInputAction: TextInputAction.next,
                                decoration: _buildInputDecoration(context, 'Email :'),
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Veuillez entrer un email'
                                    : null,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password
                            GlassContainer(
                              borderRadius: BorderRadius.circular(10),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              borderColor: primary.withOpacity(0.2),
                              blurSigma: 6.0,
                              backgroundColor: Colors.white.withOpacity(0.85),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) => _register(),
                                decoration: _buildInputDecoration(context, 'Mot de passe :'),
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Veuillez entrer un mot de passe'
                                    : null,
                                style: const TextStyle(color: Colors.black),
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

          // --------- Boutons ancrés en bas ----------
          Positioned(
            left: 0,
            right: 0,
            bottom: 12 + MediaQuery.of(context).padding.bottom,
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
                          label: _isLoading ? 'Chargement...' : "S'inscrire",
                          icon: Icons.group_add,
                          onPressed: _isLoading ? null : _register,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FormButton(
                          label: 'Se connecter',
                          icon: Icons.power_settings_new,
                          onPressed: _isLoading ? null : () => Navigator.pushNamed(context, '/'),
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
