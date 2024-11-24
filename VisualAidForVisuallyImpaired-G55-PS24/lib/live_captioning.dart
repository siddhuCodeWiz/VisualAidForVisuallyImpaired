import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'dart:convert';


class LiveCaptionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Captioning',
      home: LiveCaptionPage(),
    );
  }
}

class LiveCaptionPage extends StatefulWidget {
  @override
  _LiveCaptionPageState createState() => _LiveCaptionPageState();
}

String checkHazardous(String s) {
  List<String> words = ["knife", "fire", "water","pen"];
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

class _LiveCaptionPageState extends State<LiveCaptionPage> {
  CameraController? _cameraController;
  FlutterTts _flutterTts = FlutterTts();
  String _caption = "Waiting for caption...";
  bool _isProcessing = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTTS();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController?.initialize();
    await _cameraController?.setFlashMode(FlashMode.off);
    setState(() {});

    // Start processing frames one after another
    _processFrames();
  }

  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    // Listen for TTS completion
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _processFrames() async {
    while (mounted && _cameraController != null && _cameraController!.value.isInitialized) {
      if (!_isProcessing && !_isSpeaking) {
        _isProcessing = true;
        await _captureAndSendImage();
      }
      await Future.delayed(Duration(milliseconds: 200)); // Delay between frames
    }
  }

  Future<void> _captureAndSendImage() async {
    try {
      final XFile imageFile = await _cameraController!.takePicture();

      final String caption = await _getCaption(imageFile);
      if (caption.isNotEmpty) {
        setState(() {
          _caption = caption;
        });
        _isSpeaking = true; 
        if(checkHazardous(caption)!=""){
          void temp() async {
                final player = AudioPlayer();
                await player.setAsset('assets/audio/Alarm.mp3');
                await player.play();
                await Future.delayed(Duration(milliseconds: 500));
                await player.stop();
              }
              temp();
        }
        await _speakCaption(caption);
      }
    } catch (e) {
      print("Error capturing image: $e");
      setState(() {
        _caption = "Error in getting caption";
      });
    } finally {
      _isProcessing = false; 
    }
  }

  Future<String> _getCaption(XFile imageFile) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("http://192.168.0.103:5010/caption"),
      );

      // Attach the image file to the request
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      // Send the request and await the response
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final data = jsonDecode(responseData.body);
        return data["generated_text"] ?? "No caption available";
      } else {
        print("Failed to get caption: ${response.statusCode}");
        return "Error in getting caption";
      }
    } catch (e) {
      print("Failed to connect to the server: $e");
      return "Error in getting caption";
    }
  }

  Future<void> _speakCaption(String caption) async {
    await _flutterTts.stop();
    await _flutterTts.speak(caption);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Video Captioning")),
      body: _cameraController != null && _cameraController!.value.isInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    color: Colors.black54,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      _caption,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
