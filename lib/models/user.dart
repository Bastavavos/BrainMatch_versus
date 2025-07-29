class User {
  final String id;
  final String username;
  final String email;
  final int score;
  final String? picture;
  final List<String> friendIds;
  final List<String> friendRequestId;
  final List<String> sentFriendRequestsId;

  User({
    required this.id,
    required this.username,
    required this.score,
    required this.email,
    this.picture,
    this.friendIds = const [],
    this.friendRequestId = const [],
    this.sentFriendRequestsId = const [],

  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      score: json['score'],
      email: json['email'],
      picture: json['picture'],
      friendIds: List<String>.from(json['friends'] ?? []),
      friendRequestId: List<String>.from(json['friendRequests'] ?? []),
      sentFriendRequestsId: List<String>.from(json['sentFriendRequests'] ?? [])
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    int? score,
    String? picture,
    List<String>? friendIds,
    List<String>? friendRequestId,
    List<String>? sentFriendRequestsId,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      score: score ?? this.score,
      picture: picture ?? this.picture,
      friendIds: friendIds ?? this.friendIds,
      friendRequestId: friendRequestId ?? this.friendRequestId,
      sentFriendRequestsId: sentFriendRequestsId ?? this.sentFriendRequestsId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'score': score,
      'picture': picture,
      'friends': friendIds,
      'friendRequests': friendRequestId,
      'sentFriendRequests': sentFriendRequestsId,
    };
  }


}

extension UserImageHelper on User {
  String? get imageWithCacheBuster {
    if (picture == null || picture!.isEmpty) return null;
    return '$picture?cb=${DateTime.now().millisecondsSinceEpoch}';
  }
}
