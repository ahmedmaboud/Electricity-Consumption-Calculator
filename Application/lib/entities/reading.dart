// To parse this JSON data, do
//
//     final reading = readingFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Reading readingFromJson(String str) => Reading.fromJson(json.decode(str));
List<Reading> readingsFromJson(String str) =>
    List<Reading>.from(json.decode(str).map((x) => Reading.fromJson(x)));
String readingToJson(Reading data) => json.encode(data.toJson());

class Reading {
  final int? id;
  final DateTime? createdAt;
  final String userId;
  final int meterValue;
  final double? cost;

  Reading({
    this.id,
    this.createdAt,
    required this.userId,
    required this.meterValue,
    this.cost,
  });

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
    id: json["id"],
    createdAt: DateTime.parse(json["created_at"]),
    userId: json["user_id"],
    meterValue: json["meter_value"],
    cost: (json["cost"] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt?.toIso8601String(),
    "user_id": userId,
    "meter_value": meterValue,
    "cost": cost,
  };
}
