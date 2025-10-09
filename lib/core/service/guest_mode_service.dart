import 'package:shared_preferences/shared_preferences.dart';

class GuestModeService {
  static const String _guestModeKey = 'is_guest_mode';
  static const String _guestSessionKey = 'guest_session_id';
  static const String _guestMessagesKey = 'guest_messages';

  // Check if user is in guest mode
  static Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? false;
  }

  // Enable guest mode
  static Future<void> enableGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, true);
    
    // Generate a session ID for this guest session
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString(_guestSessionKey, sessionId);
  }

  // Disable guest mode (when user logs in)
  static Future<void> disableGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, false);
    await prefs.remove(_guestSessionKey);
    // Optionally clear guest messages
    await prefs.remove(_guestMessagesKey);
  }

  // Get guest session ID
  static Future<String?> getGuestSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_guestSessionKey);
  }

  // Save a message for guest mode (temporary storage)
  static Future<void> saveGuestMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> messages = prefs.getStringList(_guestMessagesKey) ?? [];
    
    // Add timestamp to message
    final timestampedMessage = '${DateTime.now().toIso8601String()}: $message';
    messages.add(timestampedMessage);
    
    // Keep only last 50 messages to avoid storage issues
    if (messages.length > 50) {
      messages = messages.sublist(messages.length - 50);
    }
    
    await prefs.setStringList(_guestMessagesKey, messages);
  }

  // Get guest messages
  static Future<List<String>> getGuestMessages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_guestMessagesKey) ?? [];
  }

  // Clear guest session data
  static Future<void> clearGuestData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestModeKey);
    await prefs.remove(_guestSessionKey);
    await prefs.remove(_guestMessagesKey);
  }

  // Check if user should be prompted to sign up
  static Future<bool> shouldPromptSignUp() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> messages = prefs.getStringList(_guestMessagesKey) ?? [];
    
    // Prompt to sign up after 5 messages
    return messages.length >= 5;
  }

  // Get guest mode info for display
  static Future<Map<String, dynamic>> getGuestInfo() async {
    final isGuest = await isGuestMode();
    final sessionId = await getGuestSessionId();
    final messageCount = (await getGuestMessages()).length;
    
    return {
      'isGuest': isGuest,
      'sessionId': sessionId,
      'messageCount': messageCount,
    };
  }
}