import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

String ipAddress = '192.168.0.103';

bool _isUploading = false;

class VideoProcessingPage extends StatefulWidget {
  @override
  _VideoProcessingPageState createState() => _VideoProcessingPageState();
}

class _VideoProcessingPageState extends State<VideoProcessingPage> {
  VideoPlayerController? _videoPlayerController;
  String? videoPath;
  String _responseMessage = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSpeaking = false;

  late List<String> storedPassages;

  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();
    flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        videoPath = pickedFile.path;
        _videoPlayerController = VideoPlayerController.file(File(videoPath!))
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController?.play();
          });
      });

      await _uploadVideo();
    }
  }

  Future<void> _uploadVideo() async {
    if (videoPath == null) return;

    setState(() {
      _isUploading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$ipAddress:5002/process_video'),
    );
    request.files.add(await http.MultipartFile.fromPath('video', videoPath!));
    var response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      setState(() {
        _responseMessage = responseBody;
        _isUploading = false;
      });
      storedPassages = responseBody.split(RegExp(r'[.!?]\s*'));

      // Print the sentences to verify
      print(responseBody);
      for (int i = 0; i < storedPassages.length; i++) {
        print('Sentence $i: "${storedPassages[i].trim()}"');
      }
      await _speak(_responseMessage);
      await _askForQueries(); // Wait for queries to finish
      print('Video uploaded successfully');
    } else {
      setState(() {
        _responseMessage = 'Video upload failed';
        _isUploading = false;
      });
      await _speak(_responseMessage);
      print('Video upload failed');
    }
  }

//   Future<void> _uploadVideo() async {
//   if (videoPath == null) return;
//   setState(() {
//     _isUploading = true;
//   });
//   var request = http.MultipartRequest(
//     'POST',
//     Uri.parse('http://$ipAddress:5002/process_video'),
//   );
//   request.files.add(await http.MultipartFile.fromPath('video', videoPath!));
//   var response = await request.send();
//   if (response.statusCode == 200) {
//     String responseBody = await response.stream.bytesToString();
//     setState(() {
//       _responseMessage = responseBody;
//       _isUploading = false;
//     });
//     storedPassages = responseBody.split(RegExp(r'[.!?]\s*'));
//     // Print the sentences to verify
//     print(responseBody);
//     for (int i = 0; i < storedPassages.length; i++) {
//       print('Sentence $i: "${storedPassages[i].trim()}"');
//     }
//     await _speak(_responseMessage);
//     await _askForQueries(); // Wait for queries to finish
//     print('Video uploaded successfully');
//   } else {
//     setState(() {
//       _responseMessage = 'Video upload failed';
//       _isUploading = false;
//     });
//     await _speak(_responseMessage);
//     print('Video upload failed');
//   }
// }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    setState(() {
      _isSpeaking = true;
    });
    await flutterTts.speak(text);
    while (_isSpeaking) {
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> _askForQueries() async {
    bool validResponse = false;
    while (!validResponse) {
      await _speak("Do you have any queries? Please say yes or no.");
      validResponse = await _listenForResponse();
    }
  }

  Future<bool> _listenForResponse() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      String result = '';
      bool validResponse = false;
      _speech.listen(
        onResult: (val) => setState(() {
          result = val.recognizedWords.toLowerCase();
          _isListening = false;
          validResponse = _handleResponse(result);
        }),
      );
      while (_isListening) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      return validResponse;
    } else {
      setState(() => _isListening = false);
      return false;
    }
  }

  bool _handleResponse(String response) {
    print("Response received: $response");
    if (response == 'yes' || response == 'no') {
      if (response.contains('yes')) {
        _handleYesResponse();
      } else if (response.contains('no')) {
        return true;
      } else {
        print("Invalid response: $response");
        return false;
      }
      return true;
    } else {
      _speak("I didn't catch that. Please say yes or no.");
      return false;
    }
  }

  void _handleYesResponse() async {
    bool furtherQueries = true;
    while (furtherQueries) {
      await _speak("Please state your query.");
      String query = await _getQuery();
      print("User query: $query");
      if (query.isNotEmpty) {
        await _makeApiRequest(query);
        await _speak("Do you have any further queries? Please say yes or no.");
        furtherQueries = await _listenForFurtherQueries();
      } else {
        furtherQueries = false;
      }
    }
  }

  Future<String> _getQuery() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );

    if (available) {
      // await _speak("Please state your query.");
      setState(() => _isListening = true);
      String result = '';
      _speech.listen(
        onResult: (val) => setState(() {
          result = val.recognizedWords.toLowerCase();
          if (val.finalResult) {
            _isListening = false;
          }
        }),
        listenFor: Duration(seconds: 10),
      );

      while (_isListening) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      return result.trim();
    } else {
      setState(() => _isListening = false);
      return '';
    }
  }

  Future<void> _makeApiRequest(String query) async {
    try {
      var request = http.Request(
        'POST',
        Uri.parse('http://$ipAddress:5003/api/query'),
      );
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'query': query,
        'stored_passages': storedPassages,
      });
      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print("API Response: $responseBody");
        List<String> answers = _parseAnswers(responseBody);
        setState(() {
          _responseMessage = answers.join("\n");
        });
        print(_responseMessage);
        await _speak(_responseMessage);
      } else {
        setState(() {
          _responseMessage = 'Query processing failed';
        });
        await _speak(_responseMessage);
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'An error occurred: $e';
      });
      await _speak(
          "Error occurred while querying... Could not complete your response");
      print('An error occurred: $e');
    }
  }

  List<String> _parseAnswers(String responseBody) {
    Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
    List<String> answers = List<String>.from(jsonResponse['answers']);
    return answers;
  }

  Future<bool> _listenForFurtherQueries() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      String result = '';
      _speech.listen(
        onResult: (val) => setState(() {
          result = val.recognizedWords.toLowerCase();
          _isListening = false;
        }),
      );
      while (_isListening) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      if (result.contains('yes')) {
        return true;
      } else if (result.contains('no')) {
        return true;
      } else {
        print("Invalid response: $result");
        return await _listenForFurtherQueries();
      }
    } else {
      setState(() => _isListening = false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Processing'),
      ),
      body: Stack(
        children: [
          InkWell(
            onTap: _pickVideo,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_videoPlayerController == null ||
                          !_videoPlayerController!.value.isInitialized)
                        Text(
                          'No video selected',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        )
                      else
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          ),
                        ),
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
            ),
          ),
          if (_isUploading)
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width * 0.5 - 20,
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Video Processing'),
  //     ),
  //     body: Center(
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: SingleChildScrollView(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               // Show CircularProgressIndicator while uploading
  //               if (_isUploading)
  //                 CircularProgressIndicator()
  //               // Show video player or message if not uploading
  //               else if (_videoPlayerController == null ||
  //                       !_videoPlayerController!.value.isInitialized)
  //                 Text(
  //                   'No video selected',
  //                   style: TextStyle(fontSize: 18, color: Colors.grey),
  //                 )
  //               else
  //                 Container(
  //                   constraints: BoxConstraints(
  //                     maxWidth: MediaQuery.of(context).size.width * 0.8,
  //                     maxHeight: MediaQuery.of(context).size.height * 0.4,
  //                   ),
  //                   child: AspectRatio(
  //                     aspectRatio: _videoPlayerController!.value.aspectRatio,
  //                     child: VideoPlayer(_videoPlayerController!),
  //                   ),
  //                 ),
  //               SizedBox(height: 20),
  //               Container(
  //                 width: 300,
  //                 child: Text(
  //                   _responseMessage,
  //                   style: TextStyle(fontSize: 18, color: Colors.black),
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     // Wrap the InkWell in a GestureDetector to avoid triggering onTap when the CircularProgressIndicator is visible
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: _pickVideo,
  //       child: Icon(Icons.video_collection),
  //     ),
  //   );
  // }
}
