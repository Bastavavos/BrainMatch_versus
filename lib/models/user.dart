class User {
  final String id;
  final String username;
  final String email;
  final int score;
  final String? picture;
  final List<String> friendIds;

  User({
    required this.id,
    required this.username,
    required this.score,
    required this.email,
    this.picture,
    this.friendIds = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      score: json['score'],
      email: json['email'],
      picture: json['picture'],
      friendIds: List<String>.from(json['friends'] ?? []),
    );
  }
}
