import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:soundtotext/features/auth/service/auth_service.dart';
import 'package:soundtotext/features/home/listen_screen.dart';
import 'package:soundtotext/features/home/message_confirmation_screen.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  final TextEditingController _messageController = TextEditingController();
  String _lastWords = '';
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    initSpeech();
    _initTts();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _startListening() async {
    if (_speechEnabled) {
      setState(() {
        _isListening = true;
        _lastWords = '';
      });
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(minutes: 5), // Extended to 5 minutes
        pauseFor: const Duration(seconds: 5),  // Increased pause time
        partialResults: true,
        localeId: "en_US",
        cancelOnError: false,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          cancelOnError: false,
        ),
      );
    }
  }

  void _stopListening() async {
    setState(() => _isListening = false);
    await _speechToText.stop();
    
    // Set the recognized text to the text field after stopping
    if (_lastWords.isNotEmpty) {
      setState(() {
        _messageController.text = _lastWords;
      });
    }
  }

  void _onSpeechResult(result) {
    setState(() {
      _lastWords = result.recognizedWords;
      // Update the text field in real-time while listening
      if (_isListening) {
        _messageController.text = _lastWords;
      }
    });
  }

  Future<void> _speak() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _flutterTts.speak(_messageController.text.trim());
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageConfirmationScreen(
            message: _messageController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.emergency, color: Colors.white),
        ),
        title: const Text(
          'NeuroTalk',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                const SizedBox(height: 40),
              
                Text(
                  _isListening 
                    ? 'Listening... Tap mic to stop' 
                    : _speechEnabled 
                      ? 'Tap mic to start speaking'
                      : 'Speech recognition not available',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isListening ? Colors.blue : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Microphone Button
                GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.blue : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      boxShadow: _isListening ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 60,
                      color: _isListening ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Show recognized text in real-time
                if (_isListening && _lastWords.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      _lastWords,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                // Quick Messages
                _buildQuickMessage('I need some help'),
                const SizedBox(height: 12),
                _buildQuickMessage('Can you get me a chair ?'),
                const SizedBox(height: 12),
                _buildQuickMessage('Please call my caregiver'),
                
                const SizedBox(height: 30),
                
                // Text Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type your message here...',
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.black54),
                        onPressed: _speak,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Send Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Messages won\'t be saved unless you\'re logged in.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMessage(String message) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _messageController.text = message;
        });

        if (_messageController.text.trim().isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessageConfirmationScreen(
                message: _messageController.text.trim(),
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}