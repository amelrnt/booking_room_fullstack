import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = dotenv.env['url']!;
  final String dbName = dotenv.env['db_name']!;
  final int uid = dotenv.env['uid']! as int;
  final String apiKey = dotenv.env['api_key']!;

  Future<dynamic> _makeApiCall(String model, String method,
      [List? args, Map? kwargs]) async {
    final url = Uri.parse(baseUrl);
    final headers = {'Content-Type': 'application/json'};

    final params = {
      "service": "object",
      "method": "execute",
      "args": [dbName, uid, apiKey, model, method, args ?? [], kwargs ?? {}]
    };

    final body = jsonEncode({
      "jsonrpc": "2.0",
      "method": "call",
      "params": params,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null) {
          return data['result'];
        } else {
          print('Invalid data: $data');
          throw Exception('Invalid data received from API'); // Throw exception
        }
      } else {
        print('API Error: ${response.statusCode}');
        throw Exception('Failed to make API call'); // Throw exception
      }
    } catch (e) {
      print('Error: $e');
      rethrow; // Re-throw the exception
    }
  }

  Future<List<dynamic>> getRooms() async {
    return await _makeApiCall("conference.room", "search_read", [], {
      "fields": [
        "id",
        "name",
        "room_type",
        "room_location",
        "room_capacity",
        "description",
        "room_photos"
      ]
    });
  }

  Future<List<dynamic>> getEmployees() async {
    return await _makeApiCall("hr.employee", "search_read", [], {
      "fields": ["id", "name"]
    });
  }

  Future<List<dynamic>> getBookings(String bookingName) async {
    return await _makeApiCall("room.booking", "search_read", [
      ["name", "=", bookingName]
    ], {
      "fields": [
        "id",
        "name",
        "booking_date",
        "room_name",
        "employee_name",
        "state",
        "description"
      ]
    });
  }

  Future<void> setBookingOnGoing(int bookingId) async {
    await _makeApiCall("room.booking", "api_set_booking_on_going", [bookingId]);
  }

  Future<void> setBookingDone(int bookingId) async {
    await _makeApiCall("room.booking", "api_set_booking_done", [bookingId]);
  }

  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    await _makeApiCall("room.booking", "create", [], bookingData);
  }
}
