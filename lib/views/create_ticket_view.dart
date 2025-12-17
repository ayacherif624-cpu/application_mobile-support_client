import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ticket_model.dart';

class CreateTicketView extends StatefulWidget {
  final String userId;
  const CreateTicketView({super.key, required this.userId});

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String priorite = "Moyenne";
  String categorie = "Technique";

  bool isLoading = false;
  List<PlatformFile> pickedFiles = [];

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        pickedFiles = result.files;
      });
    }
  }

  void _createTicket() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      showSnack("Veuillez remplir tous les champs");
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      List<String> fileNames =
          pickedFiles.map((file) => file.name).toList();

      TicketModel ticket = TicketModel(
        userId: uid,
        titre: _titleController.text,
        description: _descriptionController.text,
        priorite: priorite,
        categorie: categorie,
        status: "Nouveau",
        assignerId: null,
        attachments: fileNames,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('tickets')
          .add(ticket.toMap());

      showSnack("✅ Ticket créé avec succès");
      Navigator.pop(context, true);
    } catch (e) {
      showSnack("❌ Erreur : $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              // ✅ APPBAR PERSONNALISÉ
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Créer un Ticket",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

              // ✅ CONTAINER PRINCIPAL
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [

                        // ✅ TITRE
                        _modernInput(
                          controller: _titleController,
                          label: "Titre",
                          icon: Icons.title,
                        ),

                        const SizedBox(height: 15),

                        // ✅ DESCRIPTION
                        _modernInput(
                          controller: _descriptionController,
                          label: "Description",
                          icon: Icons.description,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 20),

                        // ✅ PRIORITE
                        _modernDropdown(
                          label: "Priorité",
                          value: priorite,
                          icon: Icons.priority_high,
                          items: ["Faible", "Moyenne", "Haute"],
                          onChanged: (v) => setState(() => priorite = v!),
                        ),

                        const SizedBox(height: 15),

                        // ✅ CATEGORIE
                        _modernDropdown(
                          label: "Catégorie",
                          value: categorie,
                          icon: Icons.category,
                          items: ["Technique", "Comptabilité", "Autre"],
                          onChanged: (v) => setState(() => categorie = v!),
                        ),

                        const SizedBox(height: 25),

                        // ✅ FICHIERS
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: pickFiles,
                            icon: const Icon(Icons.attach_file),
                            label: const Text("Joindre des fichiers"),
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (pickedFiles.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: pickedFiles.map((file) {
                              return Chip(
                                backgroundColor: Colors.blue[50],
                                label: Text(file.name),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    pickedFiles.remove(file);
                                  });
                                },
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 30),

                        // ✅ BOUTON PRINCIPAL
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed:
                                isLoading ? null : _createTicket,
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Créer le Ticket",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ CHAMP TEXTE MODERNE
  Widget _modernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ✅ DROPDOWN MODERNE
  Widget _modernDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
