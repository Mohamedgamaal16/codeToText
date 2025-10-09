import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepSeekService {
  static const String _baseUrl = 'https://api.deepseek.com/chat/completions';
  static const String _apiKey = 'sk-34a14a68b2ad407bbeb5d9a116a057d4';
  
  // Generate contextual suggestions based on user input
  static Future<List<String>> generateSuggestions(String userInput) async {
    try {
      final prompt = _buildSuggestionPrompt(userInput);
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'system', 'content': prompt['system']},
            {'role': 'user', 'content': prompt['user']},
          ],
          'stream': false,
          'temperature': 0.7,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Parse the response and extract suggestions
        return _parseSuggestions(content);
      } else {
        print('DeepSeek API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackSuggestions(userInput);
      }
    } catch (e) {
      print('DeepSeek Service Error: $e');
      return _getFallbackSuggestions(userInput);
    }
  }

  static Map<String, String> _buildSuggestionPrompt(String userInput) {
    return {
      'system': '''You are an AI assistant helping sick and elderly people communicate with their nurses, caregivers, and medical staff. Your task is to provide helpful, contextual suggestions for completing their messages.

Context: This is for a healthcare communication app called NeuroTalk that helps patients, especially those who may have difficulty speaking or typing, communicate their needs clearly and urgently to medical professionals.

Guidelines:
1. Provide exactly 3 helpful, relevant suggestions
2. Each suggestion should be a complete, clear sentence
3. Focus on immediate healthcare needs and nurse communication
4. Be compassionate and understanding of patients' vulnerability
5. Make suggestions that are practical and commonly needed by sick people
6. Include urgency levels when appropriate (urgent, moderate, non-urgent)
7. Consider physical limitations, pain levels, and basic care needs
8. If the input is empty or unclear, provide general helpful medical communication phrases
9. Format your response as a simple list, one suggestion per line
10. Do not include numbers, bullets, or other formatting
11. Prioritize patient safety and clear communication with medical staff

Common patient needs to consider:
- Pain management and discomfort
- Bathroom assistance and hygiene needs
- Medication requests and concerns
- Physical mobility and positioning help
- Emotional support and family contact
- Emergency medical situations
- Basic comfort needs (food, water, temperature)
- Communication with doctors and medical team''',
      
      'user': userInput.isEmpty 
        ? 'Please provide 3 general helpful medical communication phrases for a sick person who needs to communicate with nurses and medical staff.'
        : 'A sick patient started typing: "$userInput". Please provide 3 helpful suggestions to complete this medical/healthcare communication message for speaking with nurses, doctors, or caregivers.'
    };
  }

  static List<String> _parseSuggestions(String content) {
    // Split the content by lines and clean up
    List<String> suggestions = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('-') && !line.startsWith('•'))
        .map((line) {
          // Remove any numbering like "1.", "2.", etc.
          return line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
        })
        .where((line) => line.isNotEmpty)
        .take(3)
        .toList();

    // Ensure we have exactly 3 suggestions
    if (suggestions.length < 3) {
      suggestions.addAll(_getDefaultSuggestions().take(3 - suggestions.length));
    }

    return suggestions.take(3).toList();
  }

  static List<String> _getFallbackSuggestions(String userInput) {
    // Fallback to static suggestions if API fails
    if (userInput.isEmpty) {
      return _getDefaultSuggestions();
    }

    final input = userInput.toLowerCase().trim();
    
    // Enhanced keyword-based fallback matching for healthcare
    if (input.contains('pain') || input.contains('hurt') || input.contains('ache')) {
      return [
        'I am experiencing severe pain and need help',
        'The pain is getting worse, please call the nurse',
        'I need pain medication as soon as possible'
      ];
    } else if (input.contains('help') || input.contains('need') || input.contains('assist')) {
      return [
        'I need help from my nurse urgently',
        'Please send someone to assist me',
        'I require immediate medical assistance'
      ];
    } else if (input.contains('nurse') || input.contains('doctor') || input.contains('staff')) {
      return [
        'Please call my nurse immediately',
        'I need to speak with the doctor',
        'Can a nurse come to my room please?'
      ];
    } else if (input.contains('bathroom') || input.contains('toilet') || input.contains('restroom')) {
      return [
        'I need help getting to the bathroom',
        'I need a bedpan please',
        'Urgent bathroom assistance required'
      ];
    } else if (input.contains('medicine') || input.contains('medication') || input.contains('pills')) {
      return [
        'I need my medication now',
        'I missed my medication dose',
        'My medication is making me feel unwell'
      ];
    } else if (input.contains('water') || input.contains('drink') || input.contains('thirsty')) {
      return [
        'I need water please',
        'Can someone bring me something to drink?',
        'I am very thirsty and need fluids'
      ];
    } else if (input.contains('cold') || input.contains('hot') || input.contains('temperature')) {
      return [
        'I am feeling too cold, need a blanket',
        'I am too hot, please adjust the temperature',
        'I think I have a fever'
      ];
    } else if (input.contains('fall') || input.contains('fell') || input.contains('emergency')) {
      return [
        'EMERGENCY: I have fallen and need help',
        'I am having a medical emergency',
        'Please come quickly, I need urgent help'
      ];
    } else {
      return _getDefaultSuggestions();
    }
  }

  static List<String> _getDefaultSuggestions() {
    return [
      'I need help from my nurse',
      'Please call the doctor',
      'I require medical assistance'
    ];
  }

  // Generate a more detailed emergency message
  static Future<String> generateEmergencyMessage(String situation) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system', 
              'content': '''You are helping someone in a medical emergency situation. Create a clear, urgent, but professional emergency message that can be sent to caregivers or emergency contacts. The message should be:
1. Clear and direct
2. Include the urgency level
3. Request immediate assistance
4. Be professional but convey urgency
5. Maximum 2 sentences'''
            },
            {
              'role': 'user', 
              'content': 'Emergency situation: $situation. Please create an urgent message for my caregivers.'
            },
          ],
          'stream': false,
          'temperature': 0.3,
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return 'URGENT: I need immediate medical assistance. Please come to my location right away.';
      }
    } catch (e) {
      return 'URGENT: I need immediate medical assistance. Please come to my location right away.';
    }
  }
}