import 'package:json_annotation/json_annotation.dart';

part 'report_model.g.dart';

enum ReportReason {
  inappropriate,
  hatespeech,
  spam,
  misleading,
  harmful,
  other,
}

extension ReportReasonExtension on ReportReason {
  String get displayName {
    switch (this) {
      case ReportReason.inappropriate:
        return 'เนื้อหาไม่เหมาะสม / ลามก';
      case ReportReason.hatespeech:
        return 'Hate speech / การเหยียด';
      case ReportReason.spam:
        return 'สแปม / โฆษณา';
      case ReportReason.misleading:
        return 'ข้อมูลเท็จหรือทำให้เข้าใจผิด';
      case ReportReason.harmful:
        return 'เนื้อหาที่เป็นอันตราย';
      case ReportReason.other:
        return 'อื่นๆ';
    }
  }

  String get value {
    switch (this) {
      case ReportReason.inappropriate:
        return 'inappropriate';
      case ReportReason.hatespeech:
        return 'hatespeech';
      case ReportReason.spam:
        return 'spam';
      case ReportReason.misleading:
        return 'misleading';
      case ReportReason.harmful:
        return 'harmful';
      case ReportReason.other:
        return 'other';
    }
  }
}

@JsonSerializable()
class ContentReport {
  final String? id;
  final String userId;
  final String contentId;
  final String contentType;
  final String reason;
  final String? additionalDetails;
  final String? contentSnapshot;
  final DateTime? createdAt;
  final String? status;

  ContentReport({
    this.id,
    required this.userId,
    required this.contentId,
    required this.contentType,
    required this.reason,
    this.additionalDetails,
    this.contentSnapshot,
    this.createdAt,
    this.status,
  });

  factory ContentReport.fromJson(Map<String, dynamic> json) =>
      _$ContentReportFromJson(json);

  Map<String, dynamic> toJson() => _$ContentReportToJson(this);
}