import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';

class UserWidget extends StatelessWidget {
  final User user;

  const UserWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundImage: user.picture != null
              ? CachedNetworkImageProvider(user.picture!)
              : null,
          child: user.picture == null
              ? Text(user.username[0])
              : null,
        ),
        title: Text(user.username, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Score: ${user.score}'),
        onTap: () {
          // Action lors du clic sur un utilisateur, comme aficher le detail
        },
      ),
    );
  }
}
