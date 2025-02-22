import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RoomBookingScreen extends StatefulWidget {
  final int roomId;
  final String roomName;

  RoomBookingScreen({required this.roomName, required this.roomId});

  @override
  _RoomBookingScreenState createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  DateTime? _selectedDate;
  int? _selectedEmployeeId; 
  List<dynamic> employees = [];
  String _description = '';
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    final url =
        Uri.parse(dotenv.env['url']!);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "jsonrpc": "2.0",
      "method": "call",
      "params": {
        "service": "object",
        "method": "execute",
        "args": [
          dotenv.env['db_name'],
          dotenv.env['uid'], //TODO: get from login
          dotenv.env['api_key'], //TODO: get from login
          "hr.employee",
          "search_read",
          [],
          ["id", "name"]
        ]
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result'] is List) {
          // Check if result is a list and not null
          setState(() {
            employees = data['result'];
          });
        } else {
          print('Invalid employee data: $data');
          _showErrorDialog(context, 'Failed to fetch employees: Invalid data');
        }
      } else {
        print('Error: ${response.statusCode}');
        _showErrorDialog(context, 'Failed to fetch employees');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog(context, 'An error occurred');
    }
  }

  Future<void> _bookRoom() async {
    if (_selectedDate == null || _selectedEmployeeId == null) {
      _showErrorDialog(context, 'Please select date and employee');
      return;
    }

    setState(() {
      _isBooking = true;
    });
    final url = Uri.parse(dotenv.env['url']!);
    final headers = {'Content-Type': 'application/json'};
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!); // Format date

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
          "create",
          {
            "conference_room_id": widget.roomId,
            "employee_id": _selectedEmployeeId,
            "booking_date": formattedDate,
            "description": _description,
          }
        ]
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        Navigator.pop(context); // Go back to room details on success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room booked successfully'))); // Show success message
      } else {
        print('Error booking room: ${response.statusCode}');
        _showErrorDialog(context, 'Failed to book room');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog(context, 'An error occurred');
    } finally {
      setState(() {
        _isBooking = false; // Set booking state to false
      });
    }
  }


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.roomName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: ${widget.roomName}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              children: [
                Text(_selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${_selectedDate!.toString().split(' ')[0]}'),
                IconButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2026),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  icon: Icon(Icons.calendar_today),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Other booking form fields (e.g., time, description) can be added here
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            // Employee Dropdown
            DropdownButtonFormField<int>(
              // Use int for ID
              decoration: InputDecoration(labelText: 'Employee'),
              value: _selectedEmployeeId,
              items: employees
                  .map((employee) => DropdownMenuItem<int>(
                        value: employee['id'] as int, // Cast to int
                        child: Text(employee['name']),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEmployeeId = value;
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              // Center the button
              child:  ElevatedButton(
                  onPressed: _isBooking ? null : _bookRoom,
                  child: _isBooking
                      ? CircularProgressIndicator()
                      : Text('Book Room'),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
