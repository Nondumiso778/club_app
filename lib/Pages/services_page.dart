import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final CollectionReference servicesRef =
      FirebaseFirestore.instance.collection('services');

  bool showMenu = true;
  String selectedCategory = "all";

  final List<String> categories = [
    "all",
    "pool",
    "food",
    "drink",
    "golf",
    "gym",
    "kids"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: Row(
                children: [
                  if (showMenu) _sideMenu(),
                  Expanded(child: _contentArea()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              setState(() => showMenu = !showMenu);
            },
          ),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search service",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SIDE MENU =================
  Widget _sideMenu() {
    return Container(
      width: 140,
      color: Colors.black,
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String cat = categories[index];

          return ListTile(
            selected: selectedCategory == cat,
            selectedTileColor: Colors.greenAccent,
            title: Text(
              cat.toUpperCase(),
              style: TextStyle(
                color: selectedCategory == cat ? Colors.black : Colors.white,
              ),
            ),
            onTap: () {
              setState(() {
                selectedCategory = cat;
              });
            },
          );
        },
      ),
    );
  }

  // ================= CONTENT =================
  Widget _contentArea() {
    return StreamBuilder<QuerySnapshot>(
      stream: servicesRef.where("isActive", isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        final filtered = selectedCategory == "all"
            ? docs
            : docs.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return data['icon'] == selectedCategory;
              }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroSection(),
              const SizedBox(height: 16),
              _sectionTitle("Featured"),
              _horizontalScroll(filtered),
              const SizedBox(height: 16),
              _sectionTitle("Services"),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _servicesList(filtered),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= HERO =================
  Widget _heroSection() {
    return Stack(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Image.asset(
            'assets/images/club_entrance.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const Positioned(
          bottom: 16,
          left: 16,
          child: Text(
            "Explore Our Services",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  // ================= TITLE =================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= HORIZONTAL =================
  Widget _horizontalScroll(List docs) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        itemBuilder: (context, index) {
          var data = docs[index].data() as Map<String, dynamic>;

          return Container(
            width: 200,
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: (data['images'] != null && data['images'].isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(data['images'][0]),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.bottomLeft,
              child: Text(
                data['name'] ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= IMAGE SLIDER =================
  Widget _imageSlider(List<String> images) {
    PageController controller = PageController();

    return SizedBox(
      height: 200,
      child: StatefulBuilder(
        builder: (context, setState) {
          int currentPage = 0;

          return Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),

              // DOTS
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentPage == index ? 10 : 6,
                      height: currentPage == index ? 10 : 6,
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? Colors.greenAccent
                            : Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= SERVICES LIST =================
  Widget _servicesList(List docs) {
    if (docs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No services available",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Column(
      children: docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        return Container(
          key: ValueKey(data['name']),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data['images'] != null && data['images'].isNotEmpty)
                _imageSlider(List<String>.from(data['images'])),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data['description'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
