import 'dart:convert';
import 'package:brain_match/ui/layout/special_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../provider/user_provider.dart';
import '../../theme.dart';
import '../../widgets/arrow.dart';
import 'category_confirmation.dart';

class CategorySelectionPage extends ConsumerStatefulWidget {
  final String selectedMode;

  const CategorySelectionPage({super.key, required this.selectedMode});

  @override
  ConsumerState<CategorySelectionPage> createState() =>
      _CategorySelectionPageState();
}

class _CategorySelectionPageState extends ConsumerState<CategorySelectionPage>
    with TickerProviderStateMixin {
  List<dynamic> categories = [];
  bool isLoading = true;
  late AnimationController _textController;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    fetchCategories();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textController.forward();
  }

  Future<void> fetchCategories() async {
    final baseUrl = dotenv.env['API_KEY'];
    final token = ref.read(tokenProvider);

    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token manquant ou invalide.')),
        );
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quiz/category'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          categories = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement : $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final token = ref.watch(tokenProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isSolo = widget.selectedMode == 'Solo';
    final accentColor = isSolo ? colorScheme.primary : colorScheme.secondary;

    if (token == null || token.isEmpty) {
      return Scaffold(
        body: Center(child: Text('Token manquant. Veuillez vous reconnecter.')),
      );
    }

    return SpeLayout(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 50,
                          ),

                          FadeTransition(
                            opacity: _textOpacity,
                            child: Text(
                              'Choisis un thème',
                              style: TextStyle(
                                fontFamily: 'Luckiest Guy',
                                fontSize: 30,
                                color: AppColors.primary,
                              ),
                            ),
                          ),


                          Center(
                            child: BouncingArrow(
                              size: 52,
                              duration: Duration(seconds: 1),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ), // espace entre le texte et les cards
                          ...categories.map((category) {
                            final heroTag = 'category-logo-${category["_id"]}';

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              color: colorScheme.surface,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CategoryConfirmationPage(
                                        categoryId: category["_id"],
                                        title: category['theme'],
                                        description: category['description'],
                                        imageUrl: category['image'],
                                        logoUrl: category['logo'],
                                        mode: widget.selectedMode,
                                        currentUser: 'username',
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Hero(
                                        tag: heroTag,
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(
                                            category['logo'],
                                          ),
                                          backgroundColor: colorScheme.primary
                                              .withOpacity(0.1),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Text(
                                          category['theme'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Mulish',
                                            fontSize: 16,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
