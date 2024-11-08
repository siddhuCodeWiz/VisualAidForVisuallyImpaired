// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';

const String url = "http://172.168.11.78:5010";

// void main() {
//   runApp(MyApp());
// }
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Volunteer App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: VolunteerScreen(),
//     );
//   }
// }
// class VolunteerScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Visual Aid App'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: InkWell(
//               onTap: () {
//                 _speak("Entered visual assistance page");
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => VisualAssistancePage()),
//                 );
//               },
//               child: Container(
//                 color: Colors.lightBlue.shade500,
//                 child: Center(
//                   child: Text(
//                     'Do you need visual assistance?',
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => VolunteerPage()),
//                 );
//               },
//               child: Container(
//                 color: Colors.white,
//                 child: Center(
//                   child: Text(
//                     'I would like to volunteer.',
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class VisualAssistancePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Visual Assistance Page'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: InkWell(
//               onTap: () {
//                 _speak("tap anywhere to capture an image");
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ImageUploadScreen()),
//                 );
//               },
//               child: Container(
//                 color: Colors.lightBlue,
//                 child: Center(
//                   child: Text(
//                     'Image and Video Processor',
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: InkWell(
//               onTap: () {
//                 _speak("Ask your questions by calling jarvis");
//               },
//               child: Container(
//                 color: Colors.white70,
//                 child: Center(
//                   child: Text(
//                     'Talk with Chat bot',
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: InkWell(
//               onTap: () {
//                 _speak("now you can call your volunteer");
//               },
//               child: Container(
//                 color: Colors.lightBlue.shade500,
//                 child: Center(
//                   child: Text(
//                     'Call My Volunteer',
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
      Uri.parse('http://172.168.11.78:5010/conversations'),
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
                final response = chat['response'];
                final imageBase64 = chat['image_file'];
                final imageBytes = base64Decode(imageBase64);
                final TextEditingController responseController =
                    TextEditingController();

                return ListTile(
                  contentPadding: EdgeInsets.all(8.0),
                  title: Text(caption ?? 'No Caption'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.memory(imageBytes),
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

    final httpResponse = await http.post(
      Uri.parse(url + 'updateresponse'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(responseMap),
    );

    return httpResponse.statusCode == 200;
  }
}

// FlutterTts flutterTts = FlutterTts();
// Future<void> _speak(String text) async {
//   await flutterTts.setLanguage("en-US");
//   await flutterTts.setPitch(1.0);
//   await flutterTts.setSpeechRate(0.5);
//   await flutterTts.speak(text);
// }
// class ImageUploadScreen extends StatefulWidget {
//   @override
//   _ImageUploadScreenState createState() => _ImageUploadScreenState();
// }
// class _ImageUploadScreenState extends State<ImageUploadScreen> {
//   File? _image;
//   String _responseMessage = '';
//   Future<void> _getImageAndUpload() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//       await _uploadImage();
//     }
//   }
//   Future<void> _uploadImage() async {
//     if (_image == null) {
//       _showSnackbar('Please select an image');
//       return;
//     }
//     var link = url + 'caption'; // Update with your server URL
//     var request = http.MultipartRequest('POST', Uri.parse(link));
//     request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
//     try {
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         String responseBody = await response.stream.bytesToString();
//         setState(() {
//           _responseMessage = responseBody;
//           _speak(_responseMessage);
//         });
//         _showSnackbar('Image uploaded successfully :)');
//       } else {
//         _showSnackbar('Failed to upload image. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       _showSnackbar('Error uploading image: $e');
//     }
//   }
//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image and Video Processing'),
//       ),
//       body: InkWell(
//         onTap: _getImageAndUpload,
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _image == null
//                       ? Text('No image selected',
//                       style: TextStyle(fontSize: 18, color: Colors.grey))
//                       : Container(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                       maxHeight: MediaQuery.of(context).size.height * 0.4,
//                     ),
//                     child: Image.file(
//                       _image!,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Container(
//                     width: 300,
//                     child: Text(
//                       _responseMessage,
//                       style: TextStyle(fontSize: 18, color: Colors.black),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }