import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'api_service.dart';
import 'common_widgets.dart';

class RoomBookingScreen extends StatefulWidget {
  final int roomId;
  final String roomName;

  RoomBookingScreen({required this.roomName, required this.roomId});

  @override
  _RoomBookingScreenState createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  final ApiService _apiService = ApiService();
  DateTime? _selectedDate;
  int? _selectedEmployeeId;
  List<dynamic> employees = [];
  bool _isBooking = false;
  String _description = "";

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      employees = await _apiService.getEmployees();
      setState(() {});
    } catch (e) {
      showErrorDialog(context, 'Failed to fetch employees: $e');
    }
  }

  Future<void> _bookRoom() async {
    if (_selectedDate == null || _selectedEmployeeId == null) {
      showErrorDialog(context, 'Please select date and employee');
      return;
    }

    setState(() {
      _isBooking = true;
    });
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      await _apiService.createBooking({
        "conference_room_id": widget.roomId,
        "employee_id": _selectedEmployeeId,
        "booking_date": formattedDate,
        "description": _description,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Room booked successfully')));
    } catch (e) {
      showErrorDialog(context, 'Failed to book room: $e');
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
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
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Employee'),
              value: _selectedEmployeeId,
              items: employees
                  .map((employee) => DropdownMenuItem<int>(
                        value: employee['id'] as int,
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
              child: ElevatedButton(
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
