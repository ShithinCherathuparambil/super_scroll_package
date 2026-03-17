class CommunityModel {
  final int id;
  final String uid;
  final String name;
  final int member;
  final int post;
  final String? logo;
  final bool isFollowed;
  final bool specialityCommunity;

  CommunityModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.member,
    required this.post,
    this.logo,
    required this.isFollowed,
    required this.specialityCommunity,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] ?? 0,
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      member: json['member'] ?? 0,
      post: json['post'] ?? 0,
      logo: json['logo'],
      isFollowed: json['is_followed'] ?? false,
      specialityCommunity: json['speciality_community'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'member': member,
      'post': post,
      'logo': logo,
      'is_followed': isFollowed,
      'speciality_community': specialityCommunity,
    };
  }
}
