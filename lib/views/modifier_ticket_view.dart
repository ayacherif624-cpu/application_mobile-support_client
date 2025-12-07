import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../controllers/ticket_controller.dart';
import '../models/ticket.dart';

class ModifierTicketView extends StatefulWidget {
  final TicketModel ticket;

  const ModifierTicketView({super.key, required this.ticket});

  @override
  State<ModifierTicketView> createState() => _ModifierTicketViewState();
}

class _ModifierTicketViewState extends State<ModifierTicketView> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late String priorite;
  late String categorie;

  bool isLoading = false;

  // ✅ FICHIERS
  List<String> existingAttachments = [];
  List<PlatformFile> newFiles = [];
  List<String> uploadedUrls = [];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.ticket.titre);
    descriptionController =
        TextEditingController(text: widget.ticket.description);

    priorite = widget.ticket.priorite;
    categorie = widget.ticket.categorie;

    existingAttachments = List.from(widget.ticket.attachments);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ===========================
  // ✅ PICK FILES ANDROID SAFE
  // ===========================
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true, // ✅ OBLIGATOIRE
    );

    if (result != null) {
      setState(() {
        newFiles.addAll(result.files);
      });
    }
  }

  // ===========================
  // ✅ UPLOAD PAR BYTES (SAFE)
  // ===========================
  Future<String> uploadFileBytes(
      PlatformFile file, String ticketId) async {
    Uint8List? bytes = file.bytes;

    if (bytes == null) {
      throw Exception("Fichier illisible");
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child("tickets")
        .child(ticketId)
        .child(file.name);

    final uploadTask = ref.putData(bytes);
    final snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }

  // ===========================
  // ✅ SUPPRESSION STORAGE
  // ===========================
  Future<void> deleteFromStorage(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint("Erreur suppression fichier : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketController = Provider.of<TicketController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Modifier Ticket")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Modifier Ticket",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // ✅ TITRE
                TextField(controller: titleController),

                const SizedBox(height: 12),

                // ✅ DESCRIPTION
                TextField(controller: descriptionController, maxLines: 4),

                const SizedBox(height: 15),

                // ✅ PRIORITÉ
                DropdownButtonFormField<String>(
                  value: priorite,
                  items: ["Faible", "moyenne", "Haute"]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => priorite = val!),
                  decoration: const InputDecoration(labelText: "Priorité"),
                ),

                const SizedBox(height: 15),

                // ✅ CATÉGORIE
                DropdownButtonFormField<String>(
                  value: categorie,
                  items: ["Technique", "Comptabilité", "Autre"]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => categorie = val!),
                  decoration: const InputDecoration(labelText: "Catégorie"),
                ),

                const SizedBox(height: 20),

                // ✅ FICHIERS EXISTANTS
                if (existingAttachments.isNotEmpty) ...[
                  const Text("Fichiers existants :"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: existingAttachments.map((url) {
                      return Chip(
                        label: const Text("Fichier"),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () async {
                          await deleteFromStorage(url);
                          setState(() {
                            existingAttachments.remove(url);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 15),

                // ✅ AJOUTER FICHIERS
                ElevatedButton.icon(
                  onPressed: pickFiles,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Ajouter des fichiers"),
                ),

                const SizedBox(height: 10),

                // ✅ NOUVEAUX FICHIERS
                if (newFiles.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    children: newFiles.map((file) {
                      return Chip(
                        label: Text(file.name),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            newFiles.remove(file);
                          });
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 25),

                // ✅ BOUTON ENREGISTRER
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);

                          try {
                            uploadedUrls = List.from(existingAttachments);

                            // ✅ UPLOAD NOUVEAUX FICHIERS
                            for (PlatformFile file in newFiles) {
                              String url = await uploadFileBytes(
                                  file, widget.ticket.id!);
                              uploadedUrls.add(url);
                            }

                            TicketModel updatedTicket = TicketModel(
                              id: widget.ticket.id,
                              userId: widget.ticket.userId,
                              titre: titleController.text,
                              description: descriptionController.text,
                              priorite: priorite,
                              categorie: categorie,
                              status: widget.ticket.status,
                              assignerId: widget.ticket.assignerId,
                              attachments: uploadedUrls,
                              createdAt: widget.ticket.createdAt,
                            );

                            await ticketController.modifierTicket(
                              widget.ticket.id!,
                              updatedTicket,
                            );

                            Navigator.pop(context, true);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Erreur lors de la modification : $e'),
                              ),
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Enregistrer les modifications"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
