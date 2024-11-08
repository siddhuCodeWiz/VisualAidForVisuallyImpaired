// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Question Answering App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: QuestionAnswerPage(),
//     );
//   }
// }

// class QuestionAnswerPage extends StatefulWidget {
//   @override
//   _QuestionAnswerPageState createState() => _QuestionAnswerPageState();
// }

// class _QuestionAnswerPageState extends State<QuestionAnswerPage> {
//   final TextEditingController _controller = TextEditingController();
//   String answer = '';
//   late stt.SpeechToText _speech; // Use late keyword here

//   FlutterTts flutterTts = FlutterTts();
//   bool _isListening = false;

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText(); // Initialize _speech here
//     initTts();
//   }

//   Future<void> initTts() async {
//     await flutterTts.setLanguage('en-US');
//     await flutterTts.setPitch(1);
//     await flutterTts.setSpeechRate(0.5);
//   }

//   Future<void> fetchAnswer(String query) async {
//     final url = 'http://localhost:5000/answer'; // Replace with your Python backend URL
//     final response = await http.post(
//       Uri.parse(url),
//       body: {'query': query},
//     );
//     if (response.statusCode == 200) {
//       setState(() {
//         answer = response.body;
//       });
//       _speakAnswer(answer);
//     } else {
//       setState(() {
//         answer = 'Failed to get answer';
//       });
//       _speakAnswer(answer);
//     }
//   }

//   Future<void> _listen() async {
//     if (!_isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (val) => print('onStatus: $val'),
//         onError: (val) => print('onError: $val'),
//       );

//       if (available) {
//         setState(() => _isListening = true);
//         _speech.listen(
//           onResult: (val) {
//             setState(() {
//               _controller.text = val.recognizedWords;
//             });
//           },
//         );
//       }
//     } else {
//       setState(() => _isListening = false);
//       _speech.stop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Question Answering App'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Do we have any questions?',
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 // Code to ask question via speech
//                 await _listen();
//                 if (_controller.text.isNotEmpty) {
//                   await fetchAnswer(_controller.text);
//                 }
//               },
//               child: Text(_isListening ? 'Listening...' : 'Ask Question'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Answer:',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 10),
//             Text(
//               answer,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _speakAnswer(String text) async {
//     await flutterTts.awaitSpeakCompletion(true);
//     await flutterTts.speak(text);
//   }
// }







import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text(
            _text,
            style: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (!available) {
    print('Speech recognition not available on this device');
    return;
  }
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}