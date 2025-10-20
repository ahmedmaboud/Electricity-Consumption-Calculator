// To parse this JSON data, do
//
//     final reading = readingFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Reading readingFromJson(String str) => Reading.fromJson(json.decode(str));
List<Reading> readingsFromJson(String str) =>
    List<Reading>.from(json.decode(str).map((x) => Reading.fromJson(x)));
String readingToJson(Reading data) => json.encode(data.toJson());

enum SourceType { manual, voice, image }

SourceType sourceTypeFromString(String value) {
  return SourceType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => SourceType.manual,
  );
}

String sourceTypeToString(SourceType type) => type.name;

class Reading {
  final int? id;
  final DateTime? createdAt;
  final String userId;
  final int meterValue;
  final int? cost;
  final SourceType sourceType;

  Reading({
    this.id,
    this.createdAt,
    required this.userId,
    required this.meterValue,
    this.cost,
    required this.sourceType,
  });

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
    id: json["id"],
    createdAt: DateTime.parse(json["created_at"]),
    userId: json["user_id"],
    meterValue: json["meter_value"],
    cost: json["cost"],
    sourceType: sourceTypeFromString(json["source_type"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt?.toIso8601String(),
    "user_id": userId,
    "meter_value": meterValue,
    "cost": cost,
    "source_type": sourceTypeToString(sourceType),
  };
}
