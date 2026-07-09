class FriendModel {
  final String id;
  final String username;
  final double reliabilityScore;
  final String? profileImageUrl;

  FriendModel({
    required this.id,
    required this.username,
    required this.reliabilityScore,
    this.profileImageUrl,
  });
}