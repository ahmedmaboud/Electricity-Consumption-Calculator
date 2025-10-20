import 'dart:convert';

import 'package:graduation_project_depi/entities/reading.dart';
import 'package:graduation_project_depi/main.dart';

class ElectricityReadingService {
  final String _tableName = 'electricity_reading';

  Future<bool> insertReading(Reading reading) async {
    try {
      await cloud.from(_tableName).insert({
        'user_id': reading.userId,
        'meter_value': reading.meterValue,
        'cost': reading.cost,
        'source_type': reading.sourceType.name,
      });
      return true;
    } on Exception catch (e) {
      print('Insert Reading Error: $e');
      return false;
    }
  }

  Future<List<Reading>> getAllReadings() async {
    try {
      final response = await cloud.from(_tableName).select();
      return readingsFromJson(json.encode(response));
    } on Exception catch (e) {
      print('Get All Readings Error: $e');
      return [];
    }
  }

  Future<List<Reading>> getUserReadings(String userId) async {
    try {
      final response = await cloud
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return readingsFromJson(json.encode(response));
    } on Exception catch (e) {
      print('Get User Readings Error: $e');
      return [];
    }
  }

  Future<double?> getLastTwoReadingsDifference(String userId) async {
    try {
      final response = await cloud
          .from(_tableName)
          .select('meter_value')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(2);

      final data = response as List;

      if (data.length < 2) {
        return null;
      }

      double latest = (data[0]['meter_value'] as num).toDouble();
      double previous = (data[1]['meter_value'] as num).toDouble();
      //print('Latest: $latest, Previous: $previous');
      return latest - previous;
    } catch (e) {
      print('Error calculating difference: $e');
      return null;
    }
  }

  Future<bool> updateReading(Reading reading) async {
    try {
      if (reading.id == null) {
        print('Update Reading Error: Missing reading ID.');
        return false;
      }

      await cloud
          .from('readings')
          .update({
            'meter_value': reading.meterValue,
            'cost': reading.cost,
            'source_type': reading.sourceType.name,
          })
          .eq('id', reading.id!);

      return true;
    } on Exception catch (e) {
      print('Update Reading Error: $e');
      return false;
    }
  }

  Future<bool> deleteReading(int id) async {
    try {
      await cloud.from(_tableName).delete().eq('id', id);
      return true;
    } on Exception catch (e) {
      print('Delete Reading Error: $e');
      return false;
    }
  }
}
