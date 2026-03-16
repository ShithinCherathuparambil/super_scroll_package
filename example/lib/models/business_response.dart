import 'business_model.dart';

class BusinessResponse {
  final String result;
  final List<BusinessModel> record;
  final bool hasNext;
  final bool hasPrevious;

  BusinessResponse({
    required this.result,
    required this.record,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory BusinessResponse.fromJson(Map<String, dynamic> json) {
    return BusinessResponse(
      result: json['result'] ?? '',
      record: (json['record'] as List?)
              ?.map((e) => BusinessModel.fromJson(e))
              .toList() ??
          [],
      hasNext: json['has_next'] ?? false,
      hasPrevious: json['has_previous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'record': record.map((v) => v.toJson()).toList(),
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }
}
