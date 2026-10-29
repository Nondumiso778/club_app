import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:club_app/Pages/login_page.dart';
import 'package:club_app/Pages/home_page.dart';
import 'package:club_app/Pages/admin_dashboard.dart';
//import 'auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green[50],
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getUserScreen(User user) async {
    try {
      print("🔥 CHECKING ROLE FOR UID: ${user.uid}");

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      print("🔥 DOC EXISTS: ${doc.exists}");
      print("🔥 DOC DATA: ${doc.data()}");

      if (!doc.exists || doc.data() == null) {
        print("❌ USER DOCUMENT NOT FOUND");
        return HomePage();
      }

      final data = doc.data() as Map<String, dynamic>;

      final role = (data['role'] ?? '').toString().trim().toLowerCase();

      print("🔥 ROLE FOUND: $role");

      if (role == 'admin') {
        print("✅ OPENING ADMIN DASHBOARD");
        return const AdminDashboard();
      }

      print("👤 OPENING CUSTOMER HOME");
      return HomePage();
    } catch (e) {
      print("❌ ROLE CHECK ERROR: $e");
      return HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ User logged in
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<Widget>(
            future: _getUserScreen(snapshot.data!),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              return roleSnapshot.data ?? HomePage();
            },
          );
        }

        // ❌ Not logged in
        return const LoginPage();
      },
    );
  }
}
