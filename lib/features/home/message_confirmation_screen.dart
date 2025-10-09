import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:soundtotext/features/home/emergancy_screen.dart';
import 'package:soundtotext/core/shared_widget/keyboard_dismisser_widget.dart';

class MessageConfirmationScreen extends StatefulWidget {
  final String message;

  const MessageConfirmationScreen({
    super.key,
    required this.message,
  });

  @override
  State<MessageConfirmationScreen> createState() => _MessageConfirmationScreenState();
}

class _MessageConfirmationScreenState extends State<MessageConfirmationScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    // Automatically speak the selected text when screen loads
    _speakSelectedText();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Set up completion handler with mounted check
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
  }

  void _speakSelectedText() async {
    if (widget.message.trim().isNotEmpty && mounted) {
      try {
        setState(() {
          _isSpeaking = true;
        });
        await _flutterTts.speak(widget.message.trim());
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
          });
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

  void _stopSpeaking() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  @override
  void dispose() {
    // Stop TTS without accessing context
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'NeuroTalk',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: Container(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: KeyboardDismisser(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
          children: [
            const SizedBox(height: 40),
            
            const Text(
              'you selected:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Selected Message
            Text(
              widget.message,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Audio controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isSpeaking ? _stopSpeaking : _speakSelectedText,
                  icon: Icon(
                    _isSpeaking ? Icons.stop : Icons.volume_up,
                    size: 32,
                    color: _isSpeaking ? Colors.red : Colors.blue,
                  ),
                ),
                if (_isSpeaking)
                  const Text(
                    'Speaking...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 60),
            
            // Send Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmergencyScreen(message: widget.message),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
            
            // Edit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  _showEditDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Choose Another Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Choose another',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: widget.message);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your message...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageConfirmationScreen(
                      message: controller.text,
                    ),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
