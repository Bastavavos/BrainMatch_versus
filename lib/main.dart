import 'package:brain_match/ui/screens/auth/login.dart';
import 'package:brain_match/ui/layout/main_layout.dart';
import 'package:brain_match/ui/screens/quiz/select_category.dart';
import 'package:brain_match/ui/screens/auth/register.dart';
import 'package:brain_match/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  dotenv.load(fileName: ".env");
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainMatch',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/confirm') {
          final selectedMode = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => CategorySelectionPage(selectedMode: selectedMode),
          );
        }

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterPage());
          case '/main':
            return MaterialPageRoute(builder: (_) => MainLayout());
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}