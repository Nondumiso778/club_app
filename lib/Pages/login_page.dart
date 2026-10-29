import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

// Import your pages
//import 'admin_dashboard.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 🔐 EMAIL LOGIN
Future<void> signInWithEmail() async {
  try {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    print("✅ LOGIN SUCCESS");

    // ❌ DO NOT NAVIGATE HERE ANYMORE
    // AuthWrapper will handle navigation automatically

  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message ?? "Login failed"),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
      ),
    );
  }
}
  // 🔵 GOOGLE LOGIN (CUSTOMERS)
  Future<void> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      var userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);

      String uid = userCredential.user!.uid;

      // 🔹 Check if user exists in Firestore
      var userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // Create customer profile
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'role': 'customer',
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📸 Background
          SizedBox.expand(
            child: Image.asset(
              'assets/images/club_entrance.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 🌫️ Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // 🔐 UI
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 📧 Email field
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔒 Password field
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔐 Admin login button
                  ElevatedButton(
                    onPressed: signInWithEmail,
                    child: const Text("Admin Login"),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "OR",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  // 🔵 Google login
                  ElevatedButton.icon(
                    onPressed: signInWithGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text("Sign in with Google"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
