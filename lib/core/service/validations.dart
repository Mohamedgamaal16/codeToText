class ValidationUtils {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    return null;
  }
  
static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرقم القومي مطلوب';
    }
    if (value.length != 14) {
      return 'الرقم القومي يجب أن يكون 14 رقم';
    }
    return null;
  }

static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'الجنس مطلوب';
    }
    return null;
  }
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل';
    }
    
    return null;
  }

  static String? validatePhoneNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'رقم الهاتف مطلوب';
  }

  // Remove spaces, dashes, parentheses, and Arabic numerals if needed
  String cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

  // Ensure it's numeric only
  if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
    return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
  }

  // Check if it starts with the correct Egyptian prefix and is 11 digits
  if (!RegExp(r'^01[0-9]{9}$').hasMatch(cleanedValue)) {
    if (cleanedValue.length != 9) {
      return 'رقم الهاتف يجب أن يتكون من ٩ رقمًا';
    }
    
    
  }

  return null;
}

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    
    if (value != originalPassword) {
      return 'كلمات المرور غير متطابقة';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    
    if (value.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    
    if (!RegExp(r'^[a-zA-Zأ-ي\s]+$').hasMatch(value)) {
      return 'الاسم يجب أن يحتوي على أحرف فقط';
    }
    
    return null;
  }
}