class User {
  final String id;
  final String username;
  final int score;
  final String? picture;

  User({
    required this.id,
    required this.username,
    required this.score,
    this.picture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      score: json['score'],
      picture: json['picture'],
    );
  }
}
