import 'package:flutter/material.dart';
import 'package:soundtotext/core/Styles/colors.dart';
import 'package:soundtotext/core/service/validations.dart';
import 'package:soundtotext/core/shared_widget/custom_button.dart';
import 'package:soundtotext/core/shared_widget/custom_text_field.dart';
import 'package:soundtotext/features/auth/service/auth_service.dart';
import 'package:soundtotext/core/service/guest_mode_service.dart';

class NeuroTalkLoginScreen extends StatefulWidget {
  const NeuroTalkLoginScreen({super.key});

  @override
  State<NeuroTalkLoginScreen> createState() => _NeuroTalkLoginScreenState();
}

class _NeuroTalkLoginScreenState extends State<NeuroTalkLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      String? error = await AuthService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
      
      setState(() => _isLoading = false);
      
        if (error == null && mounted) {
  Navigator.pushReplacementNamed(context, '/home');
}
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  void _continueAsGuest() async {
    await GuestModeService.enableGuestMode();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    // App Title
                    const Text(
                      'NeuroTalk',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // Email Field
                    CustomTextField(
                      labelText: '',
                      hintText: 'Email',
                      controller: _emailController,
                      validator: ValidationUtils.validateEmail,
                      borderRadius: 25,
                      height: 60,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    CustomTextField(
                      labelText: '',
                      hintText: 'Password',
                      isPassword: true,
                      controller: _passwordController,
                      validator: ValidationUtils.validatePassword,
                      borderRadius: 25,
                      height: 60,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Login Button
                    CustomButton(
                      labelName: _isLoading ? 'جاري تسجيل الدخول...' : 'log in',
                      color: AppColors.kRedColor,
                      textColor: AppColors.kWhiteColor,
                      height: 60,
                      borderRadius: 25,
                      fontSize: 20,
                      isBold: true,
                      onPressed: _isLoading ? null : _handleLogin,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Don't have account link
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        "Don't have an account? Click here",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                    
                    // Continue as guest
                    GestureDetector(
                      onTap: _continueAsGuest,
                      child: const Text(
                        'Continue as guest',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Info text
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Logging in allows access to emergency contact alerts and saved message history.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
