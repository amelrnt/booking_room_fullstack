import 'dart:convert';

import 'package:booking_apps/room_booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RoomSelectionScreen extends StatefulWidget {
  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
    List<dynamic> rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }


  Future<void> _fetchRooms() async {
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
          dotenv.env['uid'], //TODO: get from login
          dotenv.env['api_key'], //TODO: get from login
          "conference.room",
          "search_read",
          [],
          ["name", "room_type", "room_location", "room_capacity", "description"]
        ]
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result'] is List) {
          setState(() {
            rooms = data['result'];
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
                  builder: (context) => RoomBookingScreen(roomName: room['name'], roomId: room['id'] as int), // Pass the room ID
                ),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.meeting_room, size: 50),
                  Text('${room['name']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Type: '),
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
