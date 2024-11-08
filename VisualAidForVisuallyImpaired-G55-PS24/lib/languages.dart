// import 'package:flutter/material.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: LanguageSelectionPage(),
// //     );
// //   }
// // }


// class LanguageSelectionPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select Language'),
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             title: Text('Hindi'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => NextPage(language: 'hi-IN'),
//                 ),
//               );
//             },
//           ),
//           ListTile(
//             title: Text('English'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => NextPage(language: 'en-US'),
//                 ),
//               );
//             },
//           ),
//           // Add more languages as needed
//         ],
//       ),
//     );
//   }
// }










// class NextPage extends StatelessWidget {
//   final String language;

//   NextPage({required this.language});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Selected Language'),
//       ),
//       body: Center(
//         child: Text(
//           'Selected Language: $language',
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }








// class LanguageSelectionPage extends StatefulWidget {
//   @override
//   _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
// }

// class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   String _language = '';
//   bool _isListening = false;

//   void _listen() async {
//     await _speak("Please say Hindi, English, or Telugu to select a language.");
//     if (!_isListening) {
//       bool available = await _speech.initialize();
//       if (available) {
//         setState(() {
//           _isListening = true;
//         });
//         _speech.listen(onResult: (result) {
//           setState(() {
//             _language = result.recognizedWords.toLowerCase();
//           });
//           _checkLanguage();
//         });

//         Future.delayed(Duration(seconds: 10), () {
//           if (_isListening) {
//             _speech.stop();
//             setState(() {
//               _isListening = false;
//             });
//             _speak("Listening time is over. Please try again.");
//             // Optionally, you can restart listening here if you want
//             // _listen();
//           }
//         });
//       }
//     }
//   }

//   void _checkLanguage() async{
//     if (_language == 'hindi') {
//       await _speak("Selected language is Hindi");
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => VisualAssistancePage(language: 'hi-IN')),
//       );
//     } else if (_language == 'english') {
//       await _speak("Selected language is English");
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => VisualAssistancePage(language: 'en-US')),
//       );
//     } else if (_language == 'telugu') {
//       await _speak("Selected language is telugu");
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => VisualAssistancePage(language: 'te-IN')),
//       );
//     } else {
//       _speak(
//           "Sorry, I didn't recognize that language. Please say Hindi, English, or Telugu.");
//       _listen();
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _listen();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select Language'),
//       ),
//       body: Center(
//         child: Text(
//           _isListening
//               ? 'Listening...'
//               : 'Say a language: Hindi, English, or Telugu',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _speech.stop();
//     super.dispose();
//   }
// }
