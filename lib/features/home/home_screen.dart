import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:soundtotext/features/auth/service/auth_service.dart';
import 'package:soundtotext/features/home/helper/suggest_words_helper.dart';
import 'package:soundtotext/features/home/message_confirmation_screen.dart';
import 'package:soundtotext/core/service/guest_mode_service.dart';
import 'package:soundtotext/core/shared_widget/keyboard_dismisser_widget.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoadingSuggestions = false;
  bool _isGuestMode = false;
  int _guestMessageCount = 0;
  
  // Default quick messages
  final List<String> _defaultMessages = [
    'I need help from my nurse',
    'Please call the doctor',
    'I require medical assistance',
  ];

  @override
  void initState() {
    super.initState();
    initSpeech();
    _initTts();
    _messageController.addListener(_onTextChanged);
    _checkGuestMode();
    
    // Initialize with default messages
    _suggestions = _defaultMessages;
    _showSuggestions = true;
  }

  void _checkGuestMode() async {
    final isGuest = await GuestModeService.isGuestMode();
    final guestInfo = await GuestModeService.getGuestInfo();
    
    setState(() {
      _isGuestMode = isGuest;
      _guestMessageCount = guestInfo['messageCount'] ?? 0;
    });
  }

  void _onTextChanged() async {
    final text = _messageController.text.toLowerCase().trim();
    
    setState(() {
      _isLoadingSuggestions = true;
    });
    
    List<String> newSuggestions = [];
    
    try {
      // Use the enhanced suggestion service with AI
      newSuggestions = await SuggestionService.getSuggestions(text);
    } catch (e) {
      print('Error getting suggestions: $e');
      // Fallback to default messages
      newSuggestions = _defaultMessages;
    }

    setState(() {
      _suggestions = newSuggestions;
      _showSuggestions = true;
      _isLoadingSuggestions = false;
    });
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
        _showSuggestions = false; // Hide suggestions while listening
      });
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 5),
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
    
    if (_lastWords.isNotEmpty) {
      setState(() {
        _messageController.text = _lastWords;
      });
    }
  }

  void _onSpeechResult(result) {
    setState(() {
      _lastWords = result.recognizedWords;
      if (_isListening) {
        _messageController.text = _lastWords;
      }
    });
  }

  Future<void> _speak() async {
    if (_messageController.text.trim().isNotEmpty) {
      try {
        await _flutterTts.stop(); // Stop any ongoing speech
        await _flutterTts.speak(_messageController.text.trim());
      } catch (e) {
        print('Text-to-speech error: $e');
        // Show a snackbar if speech fails - only if widget is still mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Text-to-speech is not available'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text.trim();
      
      // Save message if in guest mode
      if (_isGuestMode) {
        await GuestModeService.saveGuestMessage(message);
        // Update guest message count
        setState(() {
          _guestMessageCount++;
        });
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageConfirmationScreen(
            message: message,
          ),
        ),
      );
    }
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      _messageController.text = suggestion;
      _showSuggestions = false;
    });
  }

  void _showGuestOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guest Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Messages sent: $_guestMessageCount'),
              const SizedBox(height: 8),
              const Text('To save your messages and access all features, consider creating an account.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Stay as Guest'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await GuestModeService.clearGuestData();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Sign Up'),
            ),
          ],
        );
      },
    );
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
          if (_isGuestMode)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  'Guest',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(_isGuestMode ? Icons.login : Icons.logout),
            onPressed: () async {
              if (_isGuestMode) {
                // For guest mode, show dialog to sign up or clear session
                _showGuestOptionsDialog();
              } else {
                // Regular logout
                await AuthService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: KeyboardDismisser(
        child: Padding(
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
                
                // Dynamic Quick Messages / Suggestions
                if (_isLoadingSuggestions)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_showSuggestions && !_isListening)
                  Column(
                    children: [
                      for (int i = 0; i < _suggestions.length; i++) ...[
                        _buildQuickMessage(_suggestions[i]),
                        if (i < _suggestions.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                
                const SizedBox(height: 30),
                
                // Text Input with Suggestions
                Column(
                  children: [
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
                  ],
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
                
                _isGuestMode ? const Text(
                  'Messages are temporarily stored in guest mode. Sign up to save permanently.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ) : const Text(
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
      ),
    );
  }

  Widget _buildQuickMessage(String message) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _messageController.text = message;
          _showSuggestions = false; // Hide suggestions after selection
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
    // Stop TTS without accessing context
    _flutterTts.stop();
    // Clear any pending suggestions
    SuggestionService.clearDebounce();
    super.dispose();
  }
}