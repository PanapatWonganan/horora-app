// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentReport _$ContentReportFromJson(Map<String, dynamic> json) =>
    ContentReport(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      contentId: json['contentId'] as String,
      contentType: json['contentType'] as String,
      reason: json['reason'] as String,
      additionalDetails: json['additionalDetails'] as String?,
      contentSnapshot: json['contentSnapshot'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$ContentReportToJson(ContentReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'contentId': instance.contentId,
      'contentType': instance.contentType,
      'reason': instance.reason,
      'additionalDetails': instance.additionalDetails,
      'contentSnapshot': instance.contentSnapshot,
      'createdAt': instance.createdAt?.toIso8601String(),
      'status': instance.status,
    };
