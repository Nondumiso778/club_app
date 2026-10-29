import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AdminServicesManager extends StatefulWidget {
  const AdminServicesManager({super.key});

  @override
  State<AdminServicesManager> createState() => _AdminServicesManagerState();
}

class _AdminServicesManagerState extends State<AdminServicesManager> {
  final CollectionReference servicesRef =
      FirebaseFirestore.instance.collection('services');

  final List<String> iconOptions = [
    "pool",
    "food",
    "drink",
    "golf",
    "gym",
    "kids"
  ];

  final ImagePicker _picker = ImagePicker();
//bool _isSaving = false;
  Uint8List? _imageBytes;

  // ================= PICK IMAGE =================
  Future<void> _pickImage(StateSetter setStateDialog) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();

      setStateDialog(() {
        _imageBytes = bytes;
      });
    }
  }

  // ================= UPLOAD IMAGE =================
  Future<String?> _uploadImage(Uint8List bytes) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('services/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("🔥 Image upload error: $e");
      return null;
    }
  }

  // ================= ADD / EDIT DIALOG =================
  void _showServiceDialog({String? docId, Map<String, dynamic>? data}) {
    bool isSaving = false;
    TextEditingController nameCtrl =
        TextEditingController(text: data?['name'] ?? '');

    TextEditingController descCtrl =
        TextEditingController(text: data?['description'] ?? '');

    String selectedIcon = data?['icon'] ?? "pool";
    bool isActive = data?['isActive'] ?? true;

    _imageBytes = null;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(docId == null ? "Add Service" : "Edit Service"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IMAGE PREVIEW
                    _imageBytes != null
                        ? Image.memory(_imageBytes!, height: 120)
                        : (data != null &&
                                data['images'] != null &&
                                data['images'].isNotEmpty)
                            ? Image.network(data['images'][0], height: 120)
                            : const Text("No image selected"),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: () => _pickImage(setStateDialog),
                      icon: const Icon(Icons.image),
                      label: const Text("Pick Image"),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: nameCtrl,
                      decoration:
                          const InputDecoration(labelText: "Service Name"),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: descCtrl,
                      decoration:
                          const InputDecoration(labelText: "Description"),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      initialValue: selectedIcon,
                      decoration: const InputDecoration(labelText: "Icon"),
                      items: iconOptions.map((icon) {
                        return DropdownMenuItem(
                          value: icon,
                          child: Text(icon.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedIcon = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Active"),
                        Switch(
                          value: isActive,
                          onChanged: (val) {
                            setStateDialog(() {
                              isActive = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================= ACTIONS =================
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setStateDialog(() => isSaving = true);

                          print("🔥 SAVE CLICKED");

                          try {
                            if (nameCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Service name is required")),
                              );
                              // // setState(() => _isSaving = false);
                              return;
                            }

                            List<String> images = [];

                            if (data != null && data['images'] != null) {
                              images = List<String>.from(data['images']);
                            }

                            if (_imageBytes != null) {
                              print("⬆️ Uploading image...");
                              String? url = await _uploadImage(_imageBytes!);

                              if (url != null) {
                                images.add(url);
                                print("📸 Uploaded: $url");
                              } else {
                                print("❌ Upload failed");
                              }
                            }

                            final serviceData = {
                              "name": nameCtrl.text.trim(),
                              "description": descCtrl.text.trim(),
                              "icon": selectedIcon,
                              "images": images,
                              "isActive": isActive,
                              "updatedAt": FieldValue.serverTimestamp(),
                            };

                            print("💾 Saving...");

                            if (docId == null) {
                              serviceData["createdAt"] =
                                  FieldValue.serverTimestamp();
                              await servicesRef.add(serviceData);
                            } else {
                              await servicesRef.doc(docId).update(serviceData);
                            }

                            print("✅ SAVE SUCCESS");

                            if (!context.mounted) return;

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Saved successfully")),
                            );
                          } catch (e) {
                            print("🔥 SAVE ERROR: $e");
                          }

                          setStateDialog(() => isSaving = false);
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ================= DELETE =================
  void _deleteService(String id) {
    servicesRef.doc(id).delete();
  }

  // ================= ICONS =================
  IconData _getIcon(String icon) {
    switch (icon) {
      case "pool":
        return Icons.pool;
      case "food":
        return Icons.restaurant;
      case "drink":
        return Icons.local_bar;
      case "golf":
        return Icons.sports_golf;
      case "gym":
        return Icons.fitness_center;
      case "kids":
        return Icons.park;
      default:
        return Icons.circle;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: servicesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;
              bool active = data['isActive'] ?? true;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: (data['images'] != null && data['images'].isNotEmpty)
                      ? Image.network(
                          data['images'][0],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          _getIcon(data['icon'] ?? ""),
                          color: active ? Colors.green : Colors.grey,
                        ),
                  title: Text(data['name'] ?? ''),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: active,
                        onChanged: (val) {
                          servicesRef.doc(doc.id).update({
                            "isActive": val,
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteService(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
