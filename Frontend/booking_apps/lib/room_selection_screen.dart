import 'package:booking_apps/room_booking_screen.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';
import 'common_widgets.dart';

class RoomSelectionScreen extends StatefulWidget {
  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      rooms = await _apiService.getRooms();
      setState(() {});
    } catch (e) {
      showErrorDialog(context, 'Failed to fetch rooms: $e'); // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Selection'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return GestureDetector(
            // Make grid items tappable
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomBookingScreen(
                      roomName: room['name'],
                      roomId: room['id'] as int), // Pass the room ID
                ),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.meeting_room, size: 50),
                  Text('${room['name']}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Type: ${room['room_type'] ?? '-'}'),
                  Text('Location: ${room['room_location'] ?? '-'}'),
                  Text('Capacity: ${room['room_capacity'] ?? '-'}'),
                  Text('Description: ${room['description'] ?? '-'}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
