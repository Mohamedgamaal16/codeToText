import 'package:flutter_test/flutter_test.dart';
import 'package:soundtotext/core/service/deepseek_service.dart';
import 'package:soundtotext/core/service/guest_mode_service.dart';
import 'package:soundtotext/features/home/helper/suggest_words_helper.dart';

void main() {
  group('NeuroTalk Enhanced Features Tests', () {
    test('DeepSeek Service should handle empty input', () async {
      // Test that DeepSeek service returns fallback suggestions for empty input
      final suggestions = await DeepSeekService.generateSuggestions('');
      expect(suggestions.length, 3);
      expect(suggestions.every((s) => s.isNotEmpty), true);
    });
    
    test('Guest Mode Service basic functionality', () async {
      // Test guest mode enable/disable
      await GuestModeService.enableGuestMode();
      expect(await GuestModeService.isGuestMode(), true);
      
      await GuestModeService.disableGuestMode();
      expect(await GuestModeService.isGuestMode(), false);
    });
    
    test('Suggestion Service fallback functionality', () async {
      // Test static suggestions when AI is disabled
      SuggestionService.setAIEnabled(false);
      final suggestions = await SuggestionService.getSuggestions('help');
      expect(suggestions.length, lessThanOrEqualTo(3));
      expect(suggestions.every((s) => s.isNotEmpty), true);
    });
    
    test('Emergency suggestions should be available', () async {
      final emergencySuggestions = await SuggestionService.getEmergencySuggestions();
      expect(emergencySuggestions.length, 3);
      expect(emergencySuggestions.every((s) => s.toLowerCase().contains('emergency') || s.toLowerCase().contains('help') || s.toLowerCase().contains('911')), true);
    });
  });
}