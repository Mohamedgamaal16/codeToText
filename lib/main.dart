import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:soundtotext/features/auth/login.dart';
import 'package:soundtotext/features/auth/signup.dart';
import 'package:soundtotext/features/home/home_screen.dart';
import 'package:soundtotext/core/service/guest_mode_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NeuroTalkApp());
}

class NeuroTalkApp extends StatelessWidget {
  const NeuroTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeuroTalk',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      home: FutureBuilder<bool>(
        future: GuestModeService.isGuestMode(),
        builder: (context, guestSnapshot) {
          if (guestSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // If in guest mode, go directly to home
          if (guestSnapshot.data == true) {
            return const HomeScreen();
          }
          
          // Otherwise, check Firebase auth
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              // لسه بيجيب البيانات
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // لو فيه error
              if (authSnapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              }
              // لو فيه user (الـ Firebase مش فاضي) -> روح للهوم
              if (authSnapshot.hasData) {
                return const HomeScreen();
              }
              // لو مفيش user (الـ Firebase فاضي) -> روح للوجين
              return const NeuroTalkLoginScreen();
            },
          );
        },
      ),
      routes: {
        '/login': (context) => const NeuroTalkLoginScreen(),
        '/signup': (context) => const NeuroTalkSignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
