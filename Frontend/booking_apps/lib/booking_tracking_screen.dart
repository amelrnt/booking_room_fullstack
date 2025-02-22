import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BookingTrackingScreen extends StatefulWidget {
  @override
  _BookingTrackingScreenState createState() => _BookingTrackingScreenState();
}

class _BookingTrackingScreenState extends State<BookingTrackingScreen> {
  String _bookingName = '';
  List<dynamic> bookings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track your booking'),
      ),
      body: SafeArea(
        // padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Booking Name'),
              onChanged: (value) {
                _bookingName = value;
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _fetchBookings(_bookingName);
                  });
                },
                child: Text('Search'),
              ),
            ),
            SizedBox(height: 20),
            if (bookings.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${booking['name']}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['booking_date']))}'), // Format the date
                            Text('Room: ${booking['room_name']}'),
                            Text('Employee: ${booking['employee_name']}'),
                            Text('State: ${booking['state']}'),
                            Text(
                                'Description: ${booking['description'] ?? '-'}'),
                            SizedBox(height: 10),
                            if (booking['state'] == 'draft')
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _updateBookingState(
                                        booking['id'], 'on_going');
                                  },
                                  child: Text('Set to On Going'),
                                ),
                              ),
                            if (booking['state'] == 'on_going')
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _updateBookingState(booking['id'], 'done');
                                  },
                                  child: Text('Set to Done'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else if (_bookingName.isNotEmpty) ...[Text("Booking not found")]
          ],
        ),
      ),
    );
  }

  Future<void> _fetchBookings(String bookingName) async {
    final url = Uri.parse(dotenv.env['url']!);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "jsonrpc": "2.0",
      "method": "call",
      "params": {
        "service": "object",
        "method": "execute",
        "args": [
          dotenv.env['db_name'],
          dotenv.env['uid'], // TODO: get from login
          dotenv.env['api_key'], // TODO: get from login
          "room.booking",
          "search_read",
          [
            ["name", "=", bookingName]
          ],
          [
            "id",
            "name",
            "booking_date",
            "room_name",
            "employee_name",
            "state",
            "description"
          ]
        ]
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result'] is List) {
          setState(() {
            bookings = data['result'];
          });
        } else {
          print('Invalid booking data: $data');
          _showErrorDialog(context, 'Failed to fetch bookings: Invalid data');
        }
      } else {
        print('Error: ${response.statusCode}');
        _showErrorDialog(context, 'Failed to fetch bookings');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog(context, 'An error occurred');
    }
  }

  // TODO: move to commmon to reduce duplication
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBookingState(int bookingId, String newState) async {
    final url = Uri.parse(dotenv.env['url']!);
    final headers = {'Content-Type': 'application/json'};
    final method = newState == 'on_going'
        ? 'api_set_booking_on_going'
        : 'api_set_booking_done';

    final body = jsonEncode({
      "jsonrpc": "2.0",
      "method": "call",
      "params": {
        "service": "object",
        "method": "execute",
        "args": [
          dotenv.env['db_name'],
          dotenv.env['uid'],
          dotenv.env['api_key'],
          "room.booking",
          method,
          [bookingId]
        ]
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        _fetchBookings(_bookingName);
      } else {
        print('Error updating booking state: ${response.statusCode}');
        _showErrorDialog(context, 'Failed to update booking state');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog(context, 'An error occurred');
    }
  }
}
