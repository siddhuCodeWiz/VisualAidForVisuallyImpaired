// import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';

// import 'package:visual_aid/main.dart';

const String ipAddress = "192.168.0.103";


class VolunteerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoadConversations()),
                  ); // Navigate back to previous screen
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(300, 50),
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text('Images And Captions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadConversations extends StatefulWidget {
  @override
  _LoadConversationsState createState() => _LoadConversationsState();
}

class _LoadConversationsState extends State<LoadConversations> {
  Future<List<dynamic>> fetchConversations() async {
    final response = await http.get(
      Uri.parse('http://$ipAddress:5000/history'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 30), onTimeout: () {
      throw Exception('Request timed out');
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image and Caption Display'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return Center(child: Text('No conversations found'));
            }
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final chat = data[index];
                final id = chat['_id'];
                final caption = chat['caption'];
                final imageUrl = chat['image_url']; // Access the image URL
                final response = chat['response'];
                final TextEditingController responseController =
                    TextEditingController();

                return ListTile(
                  contentPadding: EdgeInsets.all(8.0),
                  title: Text(caption ?? 'No Caption'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(imageUrl), // Display image from URL
                      if (response != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            response,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (response == null)
                        TextField(
                          controller: responseController,
                          decoration: InputDecoration(
                            labelText: 'Enter Response',
                          ),
                          onSubmitted: (value) async {
                            if (value.isNotEmpty) {
                              final result = await submitResponse(id, value);
                              if (result) {
                                setState(() {
                                  chat['response'] = value;
                                });
                              }
                            }
                          },
                        ),
                      if (response == null)
                        ElevatedButton(
                          onPressed: () async {
                            final result = await submitResponse(
                                id, responseController.text);
                            if (result) {
                              setState(() {
                                chat['response'] = responseController.text;
                              });
                            }
                          },
                          child: Text('Submit Response'),
                        ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<bool> submitResponse(String id, String response) async {
    final responseMap = {
      'id': id,
      'response': response,
    };

    // _showSnackbar(responseMap);

    final httpResponse = await http.post(
      Uri.parse('http://$ipAddress:5000/updateresponse'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(responseMap),
    );

    return httpResponse.statusCode == 200;
  }
}
