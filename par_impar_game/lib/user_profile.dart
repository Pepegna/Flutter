class UserProfile {
  String gamerTag;
  int currentPoints;

  UserProfile({required this.gamerTag, required this.currentPoints});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      gamerTag: json['username'],
      currentPoints: json['pontos'] ?? 0,
    );
  }
}
