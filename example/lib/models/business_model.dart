class BusinessModel {
  final String uid;
  final String name;
  final String businessType;
  final Map<String, dynamic> logo;

  BusinessModel({
    required this.uid,
    required this.name,
    required this.businessType,
    required this.logo,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      businessType: json['business_type'] ?? '',
      logo: json['logo'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'business_type': businessType,
      'logo': logo,
    };
  }
}
