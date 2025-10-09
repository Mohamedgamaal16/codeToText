import 'package:soundtotext/core/service/deepseek_service.dart';
import 'dart:async';

// Predefined suggestions for healthcare communication
final Map<String, List<String>> suggestionMap = {
  'have': [
    'I have pain in my chest',
    'I have trouble breathing',
    'I have a headache'
  ],
  'need': [
    'I need help walking',
    'I need my medication',
    'I need to use the bathroom'
  ],
  'can': [
    'Can you help me sit up?',
    'Can you call the doctor?',
    'Can you bring me water?'
  ],
  'feel': [
    'I feel dizzy',
    'I feel nauseous',
    'I feel weak'
  ],
  'my': [
    'My back hurts',
    'My stomach is upset',
    'My head is spinning'
  ],
  'please': [
    'Please call my family',
    'Please help me stand',
    'Please bring my medicine'
  ],
  'want': [
    'I want to rest',
    'I want some water',
    'I want to see the nurse'
  ],
  'hurt': [
    'My leg hurts',
    'My arm hurts',
    'My neck hurts'
  ],
  'call': [
    'Call the doctor please',
    'Call my caregiver',
    'Call emergency services'
  ],
  'bring': [
    'Bring me a blanket',
    'Bring me my phone',
    'Bring me some food'
  ],
  // NEW KEYS ADDED BELOW
  'where': [
    'Where is my nurse?',
    'Where can I get a gown?',
    'Where is the water station?'
  ],
  'when': [
    'When is the doctor coming?',
    'When can I go home?',
    'When is my next medication due?'
  ],
  'what': [
    'What are my test results?',
    'What are my visiting hours?',
    'What did the doctor say?'
  ],
  'why': [
    'Why do I need this procedure?',
    'Why am I feeling this pain?',
    'Why is my diet restricted?',
  ],
  'how': [
    'How do I use the call button?',
    'How long will recovery take?',
    'How can I manage the pain at home?'
  ],
  'help': [
    'Help me to the chair',
    'Help, I am going to fall',
    'Help me with this device'
  ],
  'pain': [
    'The pain is getting worse',
    'The pain is a sharp stabbing',
    'My pain level is an 8 out of 10'
  ],
  'comfort': [
    'I am too cold',
    'I am too hot',
    'The pillows are uncomfortable',
  ],
  'food': [
    'I am hungry',
    'I am nauseous and cannot eat',
    'I need help cutting my food'
  ],
  'bathroom': [
    'I need a bedpan',
    'I had an accident',
    'I need privacy in the bathroom'
  ],
  'worry': [
    'I am worried about the surgery',
    'I am scared to be alone',
    'I am concerned about my family'
  ],
  'sleep': [
    'I cannot sleep',
    'The noise is keeping me awake',
    'I keep waking up in pain'
  ],
  'medication': [
    'I missed a dose of my medication',
    'The medication is making me dizzy',
    'I need a refill on my prescription'
  ],
  'family': [
    'My family needs an update',
    'How can my family visit me?',
    'My family has questions'
  ],
  'discharge': [
    'What are my discharge instructions?',
    'I need a note for my work',
    'I need my discharge paperwork'
  ],
  'thank': [
    'Thank you for your help',
    'Thank you for being patient with me',
    'I appreciate your kindness'
  ]
};

// Enhanced suggestion service that uses both AI and static suggestions
class SuggestionService {
  static bool _useAI = true;
  static Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static String _lastQuery = '';
  static List<String> _lastResults = [];
  
  // Toggle AI suggestions on/off
  static void setAIEnabled(bool enabled) {
    _useAI = enabled;
  }
  
  // Get suggestions for user input with AI enhancement and debouncing
  static Future<List<String>> getSuggestions(String userInput) async {
    final query = userInput.trim();
    
    // Return cached results if query hasn't changed
    if (query == _lastQuery && _lastResults.isNotEmpty) {
      return _lastResults;
    }
    
    // For empty input, return static suggestions immediately
    if (query.isEmpty) {
      _lastQuery = query;
      _lastResults = [
        'I need help from my nurse',
        'Can you call the doctor?',
        'I need assistance please',
      ];
      return _lastResults;
    }
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Create a completer for the debounced result
    final Completer<List<String>> completer = Completer<List<String>>();
    
    _debounceTimer = Timer(_debounceDuration, () async {
      try {
        _lastQuery = query;
        
        if (_useAI && query.isNotEmpty) {
          try {
            // First try to get AI suggestions
            final aiSuggestions = await DeepSeekService.generateSuggestions(query);
            if (aiSuggestions.isNotEmpty) {
              _lastResults = aiSuggestions;
              completer.complete(_lastResults);
              return;
            }
          } catch (e) {
            print('AI suggestions failed, falling back to static: $e');
          }
        }
        
        // Fallback to static suggestions
        final staticResults = _getStaticSuggestions(query);
        _lastResults = staticResults;
        completer.complete(staticResults);
      } catch (e) {
        // If anything fails, return default suggestions
        final defaultResults = [
          'I need help from my nurse',
          'Please call for assistance',
          'I require medical attention'
        ];
        _lastResults = defaultResults;
        completer.complete(defaultResults);
      }
    });
    
    return completer.future;
  }
  
  // Clear debounce timer and cache
  static void clearDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _lastQuery = '';
    _lastResults = [];
  }
  
  // Get static suggestions based on keywords
  static List<String> _getStaticSuggestions(String userInput) {
    final text = userInput.toLowerCase().trim();
    
    List<String> suggestions = [];
    
    if (text.isEmpty) {
      // Default suggestions when input is empty
      return [
        'I need help from my nurse',
        'Please call the doctor',
        'I require medical assistance',
      ];
    }
    
    // Find suggestions based on the text input
    for (String key in suggestionMap.keys) {
      if (key.startsWith(text) || text.contains(key)) {
        suggestions.addAll(suggestionMap[key]!);
      }
    }
    
    // Remove duplicates and limit to 3 suggestions
    suggestions = suggestions.toSet().toList();
    if (suggestions.length > 3) {
      suggestions = suggestions.sublist(0, 3);
    }
    
    // If no suggestions found, provide general help suggestions
    if (suggestions.isEmpty) {
      suggestions = [
        'I need help from my nurse',
        'Please call the doctor',
        'I require medical assistance'
      ];
    }
    
    return suggestions.take(3).toList();
  }
  
  // Get emergency-specific suggestions
  static Future<List<String>> getEmergencySuggestions() async {
    if (_useAI) {
      try {
        final aiSuggestions = await DeepSeekService.generateSuggestions('emergency help urgent');
        if (aiSuggestions.isNotEmpty) {
          return aiSuggestions;
        }
      } catch (e) {
        print('Emergency AI suggestions failed: $e');
      }
    }
    
    return [
      'EMERGENCY: I need immediate medical help',
      'Call my nurse urgently - medical emergency',
      'I am having a serious medical crisis'
    ];
  }
}