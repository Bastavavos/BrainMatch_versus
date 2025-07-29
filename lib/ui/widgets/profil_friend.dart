import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../repositories/user_repository.dart';
import '../../provider/user_provider.dart';
import '../../Service/api_service.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final token = ref.watch(tokenProvider);
  final api = ApiService(token: token);
  return UserRepository(api: api);
});

final friendRequestsProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null || currentUser.id.isEmpty) {
    debugPrint('currentUser est null ou id vide');
    return [];
  }

  return userRepository.getFriendRequests(currentUser.id);
});

class FriendRequestsWidget extends ConsumerWidget {
  const FriendRequestsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final friendRequestsAsync = ref.watch(friendRequestsProvider);
    final userRepository = ref.watch(userRepositoryProvider);

    return friendRequestsAsync.when(
      data: (requests) {

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final requester = requests[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: requester.picture != null && requester.picture!.isNotEmpty
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(requester.picture!),
                )
                    : CircleAvatar(
                  child: Text(requester.username.isNotEmpty
                      ? requester.username[0].toUpperCase()
                      : '?'),
                ),
                title: Text(requester.username),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Accepter',
                      onPressed: () async {
                        try {
                          await userRepository.acceptFriendRequest(currentUser.id, requester.id);
                          ref.read(currentUserProvider.notifier).addFriend(requester.id); // 👈 AJOUT LOCAL
                          ref.invalidate(friendRequestsProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Demande acceptée de ${requester.username}')),
                          );
                          ref.invalidate(friendRequestsProvider);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Refuser',
                      onPressed: () async {
                        try {
                          await userRepository.deleteFriendRequest(currentUser.id, requester.id);
                          ref.read(currentUserProvider.notifier).removeFriendRequest(requester.id); // 👈 MAJ LOCAL
                          ref.invalidate(friendRequestsProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Demande refusée de ${requester.username}')),
                          );
                          ref.invalidate(friendRequestsProvider);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erreur : $error')),
    );
  }
}
