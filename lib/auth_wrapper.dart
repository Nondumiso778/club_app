import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:club_app/Pages/admin_dashboard.dart';
import 'package:club_app/Pages/home_page.dart';
import 'package:club_app/Pages/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print("🔥 AUTH WRAPPER RUNNING");
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ❌ Not logged in
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // ✅ Logged in user
        User user = snapshot.data!;
print("✅ AUTH USER: ${user.email}");
print("✅ AUTH UID: ${user.uid}");
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, firestoreSnapshot) {
            // 🔄 Loading Firestore
            if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // ❌ No Firestore user
            if (!firestoreSnapshot.hasData || !firestoreSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(
                  child: Text("User record not found"),
                ),
              );
            }

            // ✅ Read role
            Map<String, dynamic> data =
                firestoreSnapshot.data!.data() as Map<String, dynamic>;

            String role =
                (data['role'] ?? 'customer').toString().trim().toLowerCase();
print("🔥 FIRESTORE DATA: $data");
print("🔥 ROLE FOUND: $role");
print("🔥 USER UID: ${user.uid}");
            print("🔥 ROLE FOUND: $role");

            // ✅ Admin
            if (role == 'admin') {
              return const AdminDashboard();
            }

            // ✅ Customer
            return HomePage();
          },
        );
      },
    );
  }
}
