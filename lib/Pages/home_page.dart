import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:club_app/Pages/login_page.dart';
import 'package:club_app/Pages/menu_page.dart';
import 'package:club_app/Pages/services_page.dart';
import 'package:club_app/Pages/orders_page.dart';
import 'package:club_app/Pages/track_order_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference specialsRef =
      FirebaseFirestore.instance.collection('Special');

  final CollectionReference eventsRef =
      FirebaseFirestore.instance.collection('Events');
  int _selectedIndex = 0; //Home Dashboard

  final Color primaryGreen = const Color.fromRGBO(0, 200, 83, 1);

  // 🍸 Glass container (reusable)
  Widget glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _homeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner

          glassContainer(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome to Ubombo Country Club"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Today's Special
          glassContainer(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder<QuerySnapshot>(
                stream: specialsRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      "Loading...",
                      style: TextStyle(color: Colors.white70),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 Heading
                      const Text(
                        "Today's Special",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🍽 Specials list
                      if (docs.isEmpty)
                        const Text(
                          "No specials available today",
                          style: TextStyle(color: Colors.white70),
                        )
                      else
                        ...docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['Title'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "E${data['Price'] ?? 0}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['Description'] ?? '',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Upcoming Events
          glassContainer(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder<QuerySnapshot>(
                  stream: eventsRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text(
                        "Loading...",
                        style: TextStyle(color: Colors.white70),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 Heading
                        const Text(
                          "Upcoming Events",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 📅 Events List
                        if (docs.isEmpty)
                          const Text(
                            "No upcoming events",
                            style: TextStyle(color: Colors.white70),
                          )
                        else
                          ...docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['EventTitle'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${data['EventCategory'] ?? ''} • E${data['EventPrice'] ?? 0}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${data['EventDate'] ?? ''} • ${data['EventLocation'] ?? ''}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          })
                      ],
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    List<Widget> pages = [
      _homeDashboard(),
      MenuPage(),
      ServicesPage(),
      OrdersPage(),
      TrackOrderPage(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
    ];

    return Scaffold(
      extendBody: true, // 🔥 IMPORTANT for glass nav

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Ubombo Country Club"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          )
        ],
      ),

      body: Stack(
        children: [
          // 🌄 BACKGROUND IMAGE
          SizedBox.expand(
            child: Image.asset(
              'assets/images/club_entrance.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 🌫 BLUR + DARK
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // 📱 CONTENT
          Column(
            children: [
              const SizedBox(height: 10),

              // 👤 USER GLASS CARD
              Padding(
                padding: const EdgeInsets.all(12),
                child: glassContainer(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.person),
                    ),
                    title: Text(
                      user?.displayName ?? "Guest",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      user?.email ?? "",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),

              // 🔥 ACTIVE PAGE
              Expanded(
                child: pages[_selectedIndex],
              ),
            ],
          ),
        ],
      ),

      // 🍸 iOS STYLE BOTTOM NAV
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: glassContainer(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                label: "Menu",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.miscellaneous_services),
                label: "Services",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: "Orders",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.track_changes),
                label: "Track",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
