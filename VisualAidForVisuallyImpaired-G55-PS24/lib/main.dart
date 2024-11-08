import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import './video_processing_page.dart';
import './loading_conversations.dart';
import './chatbot.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';

String ipAddress = '192.168.0.102';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Volunteer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VolunteerScreen(),
    );
  }
}

class VolunteerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Be My Eyes'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("Please select upper half for Enlish, middle portion for Hindi, Lower half for Telugu");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LanguageSelectionPage()),
                );
              },
              child: Container(
                color: Colors.lightBlue.shade500,
                child: Center(
                  child: Text(
                    'Do you need visual assistance?',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VolunteerPage()),
                );
              },
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    'I would like to volunteer.',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageSelectionPage extends StatelessWidget {
  // void abc() async{
  //   await _speak("Please select upper half for Enlish, middle portion for Hindi, Lower half for Telugu");
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Language'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("You have selected english");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VisualAssistancePage(language: 'en-US')),
                );
              },
              child: Container(
                color: Colors.lightBlue,
                child: Center(
                  child: Text(
                    'English',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("You have selected hindi");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VisualAssistancePage(language: 'hi-IN')),
                );
              },
              child: Container(
                color: Colors.white70,
                child: Center(
                  child: Text(
                    'Hindi',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("You have selected telugu");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VisualAssistancePage(language: 'te-IN')),
                );
              },
              child: Container(
                color: Colors.lightBlue.shade500,
                child: Center(
                  child: Text(
                    'Telugu',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VisualAssistancePage extends StatelessWidget {
  final String language;
  VisualAssistancePage({required this.language});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visual Assistance Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("tap anywhere to capture an image");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ImageUploadScreen(language: language)),
                );
              },
              child: Container(
                color: Colors.lightBlue,
                child: Center(
                  child: Text(
                    'Image Processor',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("Ask your questions by calling jarvis");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatBotApp()),
                );
              },
              child: Container(
                color: Colors.white70,
                child: Center(
                  child: Text(
                    'Talk with Chat bot',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("Entered video description page");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoProcessingPage()),
                );
              },
              child: Container(
                color: Colors.lightBlue.shade500,
                child: Center(
                  child: Text(
                    'Video Description',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class VideoProcessingPage extends StatefulWidget {
//   @override
//   _VideoProcessingPageState createState() => _VideoProcessingPageState();
// }

// class _VideoProcessingPageState extends State<VideoProcessingPage> {
//   VideoPlayerController? _videoPlayerController;
//   String? videoPath;
//   String _responseMessage = '';
//   @override
//   void initState() {
//     super.initState();
//   }
//   @override
//   void dispose() {
//     _videoPlayerController?.dispose();
//     super.dispose();
//   }
//   Future<void> _pickVideo() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         videoPath = pickedFile.path;
//         _videoPlayerController = VideoPlayerController.file(File(videoPath!))
//           ..initialize().then((_) {
//             setState(() {});
//             _videoPlayerController?.play();
//           });
//       });
//     }
//   }
//   Future<void> _uploadVideo() async {
//     if (videoPath == null) return;
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('http://$ipAddress:5002/process_video'),
//     );
//     request.files.add(await http.MultipartFile.fromPath('video', videoPath!));
//     var response = await request.send();
//     if (response.statusCode == 200) {
//       String responseBody = await response.stream.bytesToString();
//       setState(() {
//         _responseMessage = responseBody;
//         _speak(_responseMessage);
//       });
//       print('Video uploaded successfully');
//     } else {
//       setState(() {
//         _responseMessage = 'Video upload failed';
//       });
//       print('Video upload failed');
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Processing Page'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             if (_videoPlayerController != null &&
//                 _videoPlayerController!.value.isInitialized)
//               AspectRatio(
//                 aspectRatio: _videoPlayerController!.value.aspectRatio,
//                 child: VideoPlayer(_videoPlayerController!),
//               ),
//             ElevatedButton(
//               onPressed: _pickVideo,
//               child: Text('Pick Video from Gallery'),
//             ),
//             ElevatedButton(
//               onPressed: _uploadVideo,
//               child: Text('Upload Video'),
//             ),
//             SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 _responseMessage,
//                 style: TextStyle(fontSize: 18, color: Colors.black),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class VolunteerPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Volunteer Page'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'This is the Volunteer Page',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context); // Navigate back to previous screen
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade600,
//                   foregroundColor: Colors.white,
//                   textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 child: Text('History'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class ImageUploadScreen extends StatefulWidget {
  final String language;
  ImageUploadScreen({required this.language});
  @override
  _ImageUploadScreenState createState() =>
      _ImageUploadScreenState(language: language);
}

FlutterTts flutterTts = FlutterTts();

// Future<void> _speak(String text) async {
//   await flutterTts.setLanguage("en-US");
//   await flutterTts.setPitch(1.0);
//   await flutterTts.setSpeechRate(0.5);
//   await flutterTts.speak(text);
// }

Future<void> _speak(String text, {String language = "en-US"}) async {
  await flutterTts.setLanguage(language);
  await flutterTts.setPitch(0.9);
  await flutterTts.setSpeechRate(0.35);
  await flutterTts.speak(text);
}

String checkHazardous(String s) {
  List<String> words = ["knife", "fire", "water"];
  String item = "";
  // bool found = words.any((word) => s.contains(word));
  for (String word in words) {
    if (s.contains(word)) {
      return word;
    }
  }
  return item;
  // return found;
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  String _responseMessage = '';
  final String language;
  _ImageUploadScreenState({required this.language});

  Future<void> _getImageAndUpload(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      _showSnackbar('Please select an image');
      return;
    }

    var url = 'http://$ipAddress:5000/caption'; // First API endpoint
    var lang_url =
        'http://$ipAddress:5002/generate_lang'; // Second API endpoint for language generation

    var dis_url = 'http://$ipAddress:5005/estimate_distance';
    var dis_req = http.MultipartRequest('POST', Uri.parse(dis_url));
    dis_req.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));



    try {
      var response = await request.send();
      var dis_res = await dis_req.send();
      _speak(language);
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        // String sentenceResponse = _generateSentence(responseBody);
        String dis_result = await dis_res.stream.bytesToString();
        // Parse the response body and create sentences
        var dis_parsed = jsonDecode(dis_result);
        String distanceResponse = _generateSentence(dis_parsed);

        // setState(() {
        //   _responseMessage = distanceResponse;
        // });

        var langRequest = http.post(
          Uri.parse(lang_url),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode({
            'text': responseBody+distanceResponse,
            'language': language,
          }),
        );

        var langResponse = await langRequest;
        if (langResponse.statusCode == 200) {
          var langResponseBody = jsonDecode(langResponse.body);
          String langResBody = langResponseBody["result"];
          
          setState(() {
            String hazard = checkHazardous(responseBody);
            if (hazard != "") {
              _responseMessage += "\nDanger detected: $hazard\n $langResBody";
              
              // Play alarm and speak the message
              void temp() async {
                final player = AudioPlayer();
                await player.setAsset('assets/audio/Alarm.mp3');
                await player.play();
                await _speak(langResBody, language: language);
              }
              
              temp();
            } else {
              _responseMessage += "\nDESCRIPTION GENERATED: $langResBody";
              _speak(_responseMessage);
            }
          });
          _showSnackbar('Image uploaded successfully :)');
        } else {
          _showSnackbar(
              'Failed to generate language. Status code: ${langResponse.statusCode}');
        }
      } else {
        _showSnackbar(
            'Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error uploading image: $e');
    }
  }

  String _generateSentence(Map<String, dynamic> parsedResponse) {
    List<String> sentences = [];
    parsedResponse.forEach((object, details) {
      int count = details['count'];
      List<double> distances = List<double>.from(details['distances']);
      for (double distance in distances) {
        String sentence = 'There is $count $object present at a distance of ${distance.toStringAsFixed(2)} meters.';
        sentences.add(sentence);
      }
    });
    return sentences.join("\n");
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Processing'),
      ),
      body: SingleChildScrollView( // Makes the page scrollable
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _getImageAndUpload(ImageSource.camera),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Text(
                    'Take a Photo',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _getImageAndUpload(ImageSource.gallery),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Text(
                    'Choose from Gallery',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _image == null
                  ? Text('No image selected',
                      style: TextStyle(fontSize: 18, color: Colors.grey))
                  : Image.file(_image!),
              SizedBox(height: 20),
              Container(
                width: 300,
                child: Text(
                  _responseMessage,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}














// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'dart:convert';
// import 'package:assets_audio_player/assets_audio_player.dart';
// import './video_processing_page.dart';
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
//                 _speak("tap on the upper half for image processing");
//                 _speak("tap on the below half for video processing");
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => ImageAndVideoProcessing()),
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
// class ImageAndVideoProcessing extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Image And Video processing ",
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: InkWell(
//               onTap: () {
//                 _speak("tap anywhere on the screen to capture an image");
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ImageUploadScreen()),
//                 );
//               },
//               child: Container(
//                 color: Colors.lightBlue,
//                 child: Center(
//                   child: Text(
//                     'Image Processor',
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
//                 _speak("tap anywhere on the screen to capture a video");
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => VideoProcessingPage()),
//                 );
//               },
//               child: Container(
//                 color: Colors.white,
//                 child: Center(
//                   child: Text(
//                     'Video Processor',
//                     style: TextStyle(
//                         fontSize: 18,
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
// class VolunteerPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Volunteer Page'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => LoadConversations()),
//                   ); // Navigate back to previous screen
//                 },
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(300, 50),
//                   backgroundColor: Colors.blue.shade600,
//                   foregroundColor: Colors.white,
//                   textStyle:
//                       TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 child: Text('Images And Caption'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// // -------------------------------
// class LoadConversations extends StatefulWidget {
//   @override
//   _LoadConversationsState createState() => _LoadConversationsState();
// }
// class _LoadConversationsState extends State<LoadConversations> {
//   Future<List<dynamic>> fetchConversations() async {
//     final response =
//         await http.get(Uri.parse('http://192.168.241.215:5000/conversations'));
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load conversations');
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image and Caption Display'),
//       ),
//       body: FutureBuilder<List<dynamic>>(
//         future: fetchConversations(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             final data = snapshot.data ?? [];
//             if (data.isEmpty) {
//               return Center(child: Text('No conversations found'));
//             }
//             return ListView.builder(
//               itemCount: data.length,
//               itemBuilder: (context, index) {
//                 final chat = data[index];
//                 final caption = chat['caption'];
//                 final imageBase64 = chat['image_file'];
//                 final imageBytes = base64Decode(imageBase64);

//                 return ListTile(
//                   contentPadding: EdgeInsets.all(8.0),
//                   title: Text(caption ?? 'No Caption'),
//                   subtitle: Image.memory(imageBytes),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
// // -----------------------------------
// FlutterTts flutterTts = FlutterTts();
// Future<void> _speak(String text) async {
//   await flutterTts.setLanguage("en-US");
//   await flutterTts.setPitch(1.0);
//   await flutterTts.setSpeechRate(0.5);
//   await flutterTts.speak(text);
// }
// bool checkHazardous(String s) {
//   List<String> words = ["knife", "fire", "water", "sofa", "couch", "pillows"];
//   bool found = words.any((word) => s.contains(word));
//   return found;
// }
// class ImageUploadScreen extends StatefulWidget {
//   @override
//   _ImageUploadScreenState createState() => _ImageUploadScreenState();
// }
// class _ImageUploadScreenState extends State<ImageUploadScreen> {
//   File? _image;
//   String _responseMessage = '';
//   final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
//   Future<void> _playAudio(String path) async {
//     await _assetsAudioPlayer.open(
//       Audio(path),
//       autoStart: true,
//       showNotification: true,
//     );
//   }
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
//     var url =
//         'http://192.168.241.215:5000/caption'; // Update with your server URL
//     var request = http.MultipartRequest('POST', Uri.parse(url));
//     request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
//     try {
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         String responseBody = await response.stream.bytesToString();
//         setState(() {
//           _responseMessage = responseBody;
//           _speak(_responseMessage);
//         });
//         if (checkHazardous(responseBody)) {
//           await _playAudio("assets/sound/Alarm.mp3");
//         }
//         _showSnackbar('Image uploaded successfully :)');
//       } else {
//         _showSnackbar(
//             'Failed to upload image. Status code: ${response.statusCode}');
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
//         title: Text('Image Processing'),
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
//                           style: TextStyle(fontSize: 18, color: Colors.grey))
//                       : Container(
//                           constraints: BoxConstraints(
//                             maxWidth: MediaQuery.of(context).size.width * 0.8,
//                             maxHeight: MediaQuery.of(context).size.height * 0.4,
//                           ),
//                           child: Image.file(
//                             _image!,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
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