import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'api_service.dart';
import 'common_widgets.dart';

class BookingTrackingScreen extends StatefulWidget {
  @override
  _BookingTrackingScreenState createState() => _BookingTrackingScreenState();
}

class _BookingTrackingScreenState extends State<BookingTrackingScreen> {
  final ApiService _apiService = ApiService();
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
    try {
      bookings = await _apiService.getBookings(bookingName);
      setState(() {});
    } catch (e) {
      showErrorDialog(context, 'Failed to fetch bookings: $e');
    }
  }

  Future<void> _updateBookingState(int bookingId, String newState) async {
    try {
      if (newState == 'on_going') {
        await _apiService.setBookingOnGoing(bookingId);
      } else {
        await _apiService.setBookingDone(bookingId);
      }
      _fetchBookings(_bookingName);
    } catch (e) {
      showErrorDialog(context, 'Failed to update booking: $e');
    }
  }
}
