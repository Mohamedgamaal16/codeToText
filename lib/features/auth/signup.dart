import 'package:flutter/material.dart';
import 'package:soundtotext/core/Styles/colors.dart';
import 'package:soundtotext/core/service/validations.dart';
import 'package:soundtotext/core/shared_widget/custom_button.dart';
import 'package:soundtotext/core/shared_widget/custom_text_field.dart';
import 'package:soundtotext/features/auth/service/auth_service.dart';

class NeuroTalkSignUpScreen extends StatefulWidget {
  const NeuroTalkSignUpScreen({super.key});

  @override
  State<NeuroTalkSignUpScreen> createState() => _NeuroTalkSignUpScreenState();
}

class _NeuroTalkSignUpScreenState extends State<NeuroTalkSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      String? error = await AuthService.signUpWithEmailPassword(
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Title
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Name Field
                  CustomTextField(
                    labelText: '',
                    hintText: 'Full Name',
                    controller: _nameController,
                    validator: ValidationUtils.validateName,
                    borderRadius: 25,
                    height: 60,
                  ),
                  
                  const SizedBox(height: 20),
                  
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
                  
                  const SizedBox(height: 20),
                  
                  // Confirm Password Field
                  CustomTextField(
                    labelText: '',
                    hintText: 'Confirm Password',
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (value) => ValidationUtils.validateConfirmPassword(
                      value, 
                      _passwordController.text
                    ),
                    borderRadius: 25,
                    height: 60,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Sign Up Button
                  CustomButton(
                    labelName: _isLoading ? 'Creating Account...' : 'Create Account',
                    color: AppColors.kRedColor,
                    textColor: AppColors.kWhiteColor,
                    height: 60,
                    borderRadius: 25,
                    fontSize: 20,
                    isBold: true,
                    onPressed: _isLoading ? null : _handleSignUp,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Already have account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.kRedColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Fixed bottom spacing instead of Spacer
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}