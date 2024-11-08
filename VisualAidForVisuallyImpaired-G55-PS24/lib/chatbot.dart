import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ChatBotApp extends StatefulWidget {
  @override
  _ChatBotAppState createState() => _ChatBotAppState();
}

class _ChatBotAppState extends State<ChatBotApp> {
  final TextEditingController _textController = TextEditingController();
  String _response = '';
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  Future<void> _getResponse(String query) async {
    final response = await http.post(
      Uri.parse('http://172.168.11.78:5007/chat'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"query": query}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _response = jsonDecode(response.body)['response'];
      });
      _speak(_response);  // Speak the response
    } else {
      setState(() {
        _response = 'Error fetching response';
      });
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(onResult: (val) {
          setState(() {
            _textController.text = val.recognizedWords;
          });
          // Automatically send query when speech recognition is complete
          if (val.finalResult) {
            setState(() => _isListening = false);
            _getResponse(val.recognizedWords);  // Send the query
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Chatbot')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Ask me anything',
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _getResponse(_textController.text);
                    },
                    child: Text('Send'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _listen,
                    child: Text(_isListening ? 'Listening...' : 'Speak'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Response: $_response',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
