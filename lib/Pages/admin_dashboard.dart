import 'package:club_app/Pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:club_app/pages/admin_menu_page.dart';
import 'dart:ui';
import 'package:club_app/pages/admin_services_manager.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ordersRef = FirebaseFirestore.instance.collection('orders');
  final readyRef = FirebaseFirestore.instance.collection('come_and_get');
  final historyRef = FirebaseFirestore.instance.collection('orders_history');
  final menuRef = FirebaseFirestore.instance.collection('menu');
  final specialsRef = FirebaseFirestore.instance.collection('Special');
  final eventsRef = FirebaseFirestore.instance.collection('Events');

  final List<String> categories = [
    "Breakfast",
    "Starters",
    "Main Course",
    "Dessert",
    "Drinks",
    "Snacks"
  ];

  DocumentSnapshot? selectedOrder;
  DocumentSnapshot? selectedReadyOrder;
  DocumentSnapshot? selectedHistoryOrder;

  final Color primaryGreen = const Color.fromRGBO(0, 200, 83, 1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ================= LOGOUT =================
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  // ================= APP =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(icon: Icon(Icons.receipt), text: "Pending"),
            Tab(icon: Icon(Icons.check_circle), text: "Come & Get"),
            Tab(icon: Icon(Icons.history), text: "Delivered"),
            Tab(icon: Icon(Icons.room_service), text: "Services"),
            Tab(icon: Icon(Icons.fastfood), text: "Menu"),
            Tab(icon: Icon(Icons.local_offer), text: "Specials"),
            Tab(icon: Icon(Icons.event), text: "Events"),
          ],
        ),
      ),

      // 🌄 HOME PAGE STYLE BACKGROUND ADDED HERE
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/club_entrance.jpg',
              fit: BoxFit.cover,
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Actual content (tabs unchanged)
          TabBarView(
            controller: _tabController,
            children: [
              _ordersPanel(),
              _comeAndGetPanel(),
              _historyPanel(),
              _servicesPanel(),
              _menuPanel(),
              _specialsPanel(),
              _eventsPanel(),
            ],
          ),
        ],
      ),
    );
  }

  // ================= PENDING =================
  Widget _ordersPanel() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: StreamBuilder<QuerySnapshot>(
            stream:
                ordersRef.orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = snapshot.data!.docs;

              return ListView(
                children: orders.map((order) {
                  var data = order.data() as Map<String, dynamic>;

                  return glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            "Order #${data['orderRef'] ?? order.id}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Status: ${data['status'] ?? 'Pending'}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          selected: selectedOrder?.id == order.id,
                          onTap: () => setState(() => selectedOrder = order),
                        ),

                        const SizedBox(height: 8),

                        // 🔥 ACTION BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              onPressed: () async {
                                await readyRef.doc(order.id).set(data);
                                await ordersRef.doc(order.id).delete();
                              },
                              child: const Text("Ready"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: selectedOrder == null
              ? const Center(
                  child: Text("Select an order",
                      style: TextStyle(color: Colors.white)))
              : _orderDetails(selectedOrder!, isComeAndGet: false),
        ),
      ],
    );
  }

  //---------Services Panel -----
  Widget _servicesPanel() {
    return AdminServicesManager();
  }

  void _showEditSpecialDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final titleController = TextEditingController(text: data['Title']);

    final priceController = TextEditingController(
      text: data['Price'].toString(),
    );

    final descriptionController = TextEditingController(
      text: data['Description'],
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Special"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: "Price",
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await specialsRef.doc(doc.id).update({
                'Title': titleController.text,
                'Price': double.tryParse(
                      priceController.text,
                    ) ??
                    0,
                'Description': descriptionController.text,
              });

              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(
    String eventId,
    Map<String, dynamic> eventData,
  ) {
    final titleController =
        TextEditingController(text: eventData['EventTitle']);

    final categoryController =
        TextEditingController(text: eventData['EventCategory']);

    final priceController =
        TextEditingController(text: eventData['EventPrice'].toString());

    final dateController = TextEditingController(text: eventData['EventDate']);

    final locationController =
        TextEditingController(text: eventData['EventLocation']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Event Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2035),
                  );

                  if (pickedDate != null) {
                    dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  }
                },
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await eventsRef.doc(eventId).update({
                'EventTitle': titleController.text.trim(),
                'EventCategory': categoryController.text.trim(),
                'EventPrice': double.tryParse(priceController.text) ?? 0,
                'EventDate': dateController.text.trim(),
                'EventLocation': locationController.text.trim(),
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event updated successfully'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final dateController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Event"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Event Title",
                ),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "Category",
                ),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Price",
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Event Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2035),
                  );

                  if (pickedDate != null) {
                    dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  }
                },
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await eventsRef.add({
                'EventTitle': titleController.text,
                'EventCategory': categoryController.text,
                'EventPrice': double.tryParse(priceController.text) ?? 0,
                'EventDate': dateController.text,
                'EventLocation': locationController.text,
                'createdAt': Timestamp.now(),
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Event added successfully"),
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showAddSpecialDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Special"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: "Price",
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await specialsRef.add({
                'Title': titleController.text,
                'Price': double.tryParse(priceController.text) ?? 0,
                'Description': descriptionController.text,
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= COME & GET =================
  Widget _comeAndGetPanel() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: StreamBuilder<QuerySnapshot>(
            stream: readyRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              return ListView(
                children: docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  return glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            "Order #${data['orderRef'] ?? doc.id}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Status: ${data['status'] ?? 'Ready'}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          selected: selectedReadyOrder?.id == doc.id,
                          onTap: () => setState(() => selectedReadyOrder = doc),
                        ),

                        const SizedBox(height: 8),

                        // 🔥 ACTION BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                await historyRef.doc(doc.id).set(data);
                                await readyRef.doc(doc.id).delete();
                              },
                              child: const Text("Delivered"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: selectedReadyOrder == null
              ? const Center(
                  child: Text("Select a ready order",
                      style: TextStyle(color: Colors.white)))
              : _orderDetails(selectedReadyOrder!, isComeAndGet: true),
        ),
      ],
    );
  }

  // ================= ORDER DETAILS =================
  Widget _orderDetails(DocumentSnapshot order, {required bool isComeAndGet}) {
    var data = order.data() as Map<String, dynamic>;
    String id = order.id;
    List items = data['items'] ?? [];

    return glassCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${data['orderRef'] ?? id}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isComeAndGet ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data['status'] ?? "Pending",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 📞 CUSTOMER INFO
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  data['phone'] ?? 'N/A',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),

            const Divider(color: Colors.white30, height: 30),

            // 🍔 ITEMS TITLE
            const Text(
              "Order Items",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // 📋 ITEMS LIST
            Column(
              children: items.map<Widget>((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ITEM NAME + QTY
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "x${item['quantity']}",
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      // PRICE
                      Text(
                        "E${item['total']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const Divider(color: Colors.white30, height: 30),

            // 💰 TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "E${data['total'] ?? 0}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= HISTORY =================
  Widget _historyPanel() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: StreamBuilder<QuerySnapshot>(
            stream:
                historyRef.orderBy('updatedAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              return ListView(
                children: docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  return glassCard(
                      child: ListTile(
                    title: Text("Order #${data['orderRef'] ?? doc.id}",
                        style: const TextStyle(color: Colors.white)),
                    selected: selectedHistoryOrder?.id == doc.id,
                    onTap: () => setState(() => selectedHistoryOrder = doc),
                  ));
                }).toList(),
              );
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: selectedHistoryOrder == null
              ? const Center(
                  child: Text("Select a delivered order",
                      style: TextStyle(color: Colors.white)))
              : _historyOrderDetails(selectedHistoryOrder!),
        ),
      ],
    );
  }

  Widget _specialsPanel() {
    return StreamBuilder<QuerySnapshot>(
      stream: specialsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs;

        return Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Special"),
              onPressed: _showAddSpecialDialog,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(
                      data['Title'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "E${data['Price']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditSpecialDialog(doc),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => specialsRef.doc(doc.id).delete(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _eventsPanel() {
    return StreamBuilder<QuerySnapshot>(
      stream: eventsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs;

        return Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Event"),
              onPressed: _showAddEventDialog,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return ListTile(
                      title: Text(
                        data['EventTitle'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        data['EventDate'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditEventDialog(
                              doc.id,
                              doc.data() as Map<String, dynamic>,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => eventsRef.doc(doc.id).delete(),
                          ),
                        ],
                      ));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _historyOrderDetails(DocumentSnapshot order) {
    var data = order.data() as Map<String, dynamic>;
    List items = data['items'] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order #${data['orderRef']}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Phone: ${data['phone'] ?? 'N/A'}"),
            Text("Status: ${data['status'] ?? 'Delivered'}"),
            const SizedBox(height: 20),
            const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...items.map((item) => Text(
                "${item['name']} x${item['quantity']} - E${item['total']}")),
          ],
        ),
      ),
    );
  }

  // ================= MENU (UNCHANGED LOGIC) =================
  Widget _menuPanel() {
    return const AdminMenuPage(); // keeping unchanged logic area for brevity
  }
}

Widget glassCard({required Widget child}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ),
    ),
  );
}
