import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ticket.dart';

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

  // ✅ FICHIERS LOCAUX SEULEMENT
  List<PlatformFile> pickedFiles = [];

  // ===========================
  // ✅ PICK FILES (GRATUIT)
  // ===========================
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

  // ===========================
  // ✅ CREATE TICKET (SANS UPLOAD)
  // ===========================
  void _createTicket() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      showSnack("Veuillez remplir tous les champs");
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // ✅ ON GARDE JUSTE LES NOMS DES FICHIERS
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
        attachments: fileNames, // ✅ JUSTE LES NOMS
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
      appBar: AppBar(title: const Text("Créer un Ticket")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Titre"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: "Description"),
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField(
                  value: priorite,
                  items: ["Faible", "Moyenne", "Haute"]
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => priorite = v!),
                  decoration: const InputDecoration(labelText: "Priorité"),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField(
                  value: categorie,
                  items: ["Technique", "Comptabilité", "Autre"]
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => categorie = v!),
                  decoration: const InputDecoration(labelText: "Catégorie"),
                ),

                const SizedBox(height: 20),

                // ✅ JOINDRE DES FICHIERS (LOCAL)
                OutlinedButton.icon(
                  onPressed: pickFiles,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Joindre des fichiers"),
                ),

                const SizedBox(height: 10),

                if (pickedFiles.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    children: pickedFiles.map((file) {
                      return Chip(
                        label: Text(file.name),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            pickedFiles.remove(file);
                          });
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: isLoading ? null : _createTicket,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Créer Ticket"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
