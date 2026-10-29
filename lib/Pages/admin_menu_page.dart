import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  final CollectionReference menuRef =
      FirebaseFirestore.instance.collection('menu');

  final List<String> categories = [
    "Breakfast",
    "Starters",
    "Main Course",
    "Dessert",
    "Drinks",
    "Snacks"
  ];

  String searchQuery = "";

  // ================= ADD / EDIT =================
  void _showAddEditDialog({String? docId, Map? data}) {
    TextEditingController nameController =
        TextEditingController(text: data?['name'] ?? '');
    TextEditingController priceController =
        TextEditingController(text: data?['price']?.toString() ?? '');

    String? category = data?['category'];
    bool isAvailable = data?['isAvailable'] ?? true;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(docId == null ? "Add Menu Item" : "Edit Item"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Item Name"),
                    ),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Price"),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          category = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Available"),
                        Switch(
                          value: isAvailable,
                          onChanged: (val) {
                            setStateDialog(() {
                              isAvailable = val;
                            });
                          },
                        ),
                      ],
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
                  onPressed: () {
                    final item = {
                      "name": nameController.text,
                      "price": double.tryParse(priceController.text) ?? 0,
                      "category": category ?? "Uncategorized",
                      "isAvailable": isAvailable,
                      "createdAt": FieldValue.serverTimestamp(),
                    };

                    if (docId == null) {
                      menuRef.add(item);
                    } else {
                      menuRef.doc(docId).update(item);
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= TOGGLE =================
  void _toggleAvailability(String id, bool current) {
    menuRef.doc(id).update({
      "isAvailable": !current,
    });
  }

  // ================= DELETE =================
  void _deleteItem(String id) {
    menuRef.doc(id).delete();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: menuRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔍 FILTER DATA BASED ON SEARCH
          List docs = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String name = (data['name'] ?? "").toLowerCase();

            return name.contains(searchQuery);
          }).toList();

          return Column(
            children: [
              // 🔍 SEARCH BAR (NEW ONLY)
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search menu item...",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),

              // 📋 MENU LIST (UNCHANGED LOGIC)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    bool available = data['isAvailable'] ?? true;

                    return glassCard(
                      child: ListTile(
                        isThreeLine: true,

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),

                        // LEFT STATUS ICON
                        leading: Icon(
                          available ? Icons.check_circle : Icons.cancel,
                          color: available ? Colors.green : Colors.red,
                        ),

                        // TITLE
                        title: Text(
                          data['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // SUBTITLE
                        subtitle: Text(
                          "${data['category']} • E${data['price']}",
                        ),

                        // RIGHT ACTIONS
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // TOGGLE SWITCH
                            Switch(
                              value: available,
                              onChanged: (val) {
                                menuRef.doc(doc.id).update({
                                  "isAvailable": val,
                                });
                              },
                            ),

                            // EDIT
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddEditDialog(
                                docId: doc.id,
                                data: data,
                              ),
                            ),

                            // DELETE
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget glassCard({required Widget child}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          padding: const EdgeInsets.all(10),
          child: child,
        ),
      ),
    ),
  );
}
