import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ajouté
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../models/user.dart';
import '../../../provider/user_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../../service/api_service.dart';
import '../../theme.dart';

class UserProfileCard extends ConsumerStatefulWidget {
  final User user;
  final String token;
  final VoidCallback onLogout;

  const UserProfileCard({
    super.key,
    required this.user,
    required this.token,
    required this.onLogout,
  });

  @override
  ConsumerState<UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends ConsumerState<UserProfileCard> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();

    if (source == ImageSource.gallery) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission stockage refusée")),
        );
        return;
      }
    }

    final pickedFile = await _picker.pickImage(
        source: source, imageQuality: 80);

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(pickedFile.path);
      final api = ApiService(token: widget.token);
      final response = await api.uploadUserImage(widget.user.id, file);

      if (response.statusCode == 200) {
        await ref.read(currentUserProvider.notifier).refreshUser(ref);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploadée avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur upload : ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur upload : $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _editUsername() async {
    final TextEditingController controller =
    TextEditingController(text: widget.user.username);

    final newUsername = await showDialog<String>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Modifier le pseudo'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Nouveau pseudo',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Enregistrer'),
              ),
            ],
          ),
    );

    if (newUsername != null &&

        newUsername
            .trim()
            .isNotEmpty &&
        newUsername.trim() != widget.user.username) {
      try {
        final apiService = ApiService(token: widget.token);
        final repository = UserRepository(api: apiService);

        await repository.updateUserById(
          widget.user.id,
          {'username': newUsername.trim()},
        );

        await ref.read(currentUserProvider.notifier).refreshUser(ref);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pseudo mis à jour avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir dans la galerie'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  // Future<void> _confirmDeleteAccount() async {
  //   final bool? confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (context) =>
  //         AlertDialog(
  //           title: const Text('Confirmer la suppression'),
  //           content: const Text(
  //               'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: const Text('Annuler'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () => Navigator.of(context).pop(true),
  //               child: const Text('Supprimer'),
  //             ),
  //           ],
  //         ),
  //   );
  //
  //   if (confirm == true) {
  //     try {
  //       final apiService = ApiService(token: widget.token);
  //       final repository = UserRepository(api: apiService);
  //
  //       final message = await repository.deleteUserById(widget.user.id);
  //
  //       if (!mounted) return;
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(message)),
  //       );
  //
  //       widget.onLogout();
  //
  //       Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  //     } catch (e) {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Erreur lors de la suppression : $e')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    final firstLetter = (widget.user.username.isNotEmpty)
        ? widget.user.username[0].toUpperCase()
        : '?';

    final imageUrl = (widget.user.picture != null && widget.user.picture!.isNotEmpty)
        ? '${widget.user.picture!}?cb=${DateTime
        .now()
        .millisecondsSinceEpoch}'
        : null;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _isUploading ? null : _showPickerOptions,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        key: ValueKey(widget.user.picture),
                        radius: 70,
                        backgroundColor: Colors.deepPurple.shade100,
                        backgroundImage: (imageUrl != null) ? NetworkImage(
                            imageUrl) : null,
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : (imageUrl == null)
                            ? Text(
                          firstLetter,
                          style: const TextStyle(
                            fontSize: 50,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            : null,
                      ),
                    ),
                    if (!_isUploading)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.deepPurple,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.user.username,
                    style: const TextStyle(
                      fontFamily: 'Luckiest Guy',
                      fontSize: 30,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _editUsername,
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.light,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(

                widget.user.email,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 16,
                  color: AppColors.background,
                ),
              ),
              const Divider(height: 50, color: AppColors.background),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Score - ",
                    style: TextStyle(
                      fontFamily: 'Luckiest Guy',
                      fontSize: 25,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(

                    "${widget.user.score}",

                    style: const TextStyle(
                      fontFamily: 'Luckiest Guy',
                      fontSize: 25,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Positioned(
        //   top: 8,
        //   right: 8,
        //   child: ElevatedButton(
        //     onPressed: _confirmDeleteAccount,
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.red,
        //       foregroundColor: Colors.white,
        //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        //       minimumSize: const Size(0, 0),
        //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //       elevation: 2,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(20),
        //       ),
        //       textStyle: const TextStyle(
        //         fontSize: 12,
        //         fontWeight: FontWeight.w500,
        //       ),
        //     ),
        //     child: const Text('Supprimer mon compte'),
        //   ),
        // ),
      ],
    );
  }
}
