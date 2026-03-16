import 'community_model.dart';

class CommunityResponse {
  final String result;
  final List<CommunityModel> records;
  final bool hasNext;
  final bool hasPrevious;

  CommunityResponse({
    required this.result,
    required this.records,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory CommunityResponse.fromJson(Map<String, dynamic> json) {
    return CommunityResponse(
      result: json['result'] ?? '',
      records: (json['records'] as List?)
              ?.map((e) => CommunityModel.fromJson(e))
              .toList() ??
          [],
      hasNext: json['has_next'] ?? false,
      hasPrevious: json['has_previous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'records': records.map((v) => v.toJson()).toList(),
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }
}
