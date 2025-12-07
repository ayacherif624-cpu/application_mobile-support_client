import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
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
  List<String> attachments = [];
  String priority = '';
  String category = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.ticket.title);
    descriptionController = TextEditingController(text: widget.ticket.description);
    priority = widget.ticket.priority;
    category = widget.ticket.category;
    attachments = List<String>.from(widget.ticket.attachments);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        attachments.addAll(result.paths.whereType<String>());
      });
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Modifier Ticket",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Titre
                Text("Titre :", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: titleController),
                const SizedBox(height: 12),

                // Description
                Text("Description :", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: descriptionController, maxLines: 4),
                const SizedBox(height: 12),

                // Priorité (Dropdown)
                Text("Priorité :", style: const TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: priority,
                  items: ['Faible', 'Moyenne', 'Haute']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => priority = val);
                  },
                ),
                const SizedBox(height: 12),

                // Catégorie (Dropdown)
                Text("Catégorie :", style: const TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: category,
                  items: ['Technique', 'Comptabilité', 'Autre']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => category = val);
                  },
                ),
                const SizedBox(height: 20),

                // Ajouter fichiers
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Ajouter des fichiers"),
                ),
                const SizedBox(height: 12),

                // Liste des fichiers
                attachments.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: attachments
                            .map((f) => Card(
                                  color: Colors.blue.shade50,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: const Icon(Icons.insert_drive_file),
                                    title: Text(f.split('/').last),
                                    trailing: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          attachments.remove(f);
                                        });
                                      },
                                      child: const Icon(Icons.close, color: Colors.red),
                                    ),
                                  ),
                                ))
                            .toList(),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 20),

                // Enregistrer
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);

                          TicketModel updatedTicket = TicketModel(
                            id: widget.ticket.id,
                            title: titleController.text,
                            description: descriptionController.text,
                            priority: priority,
                            category: category,
                            attachments: attachments,
                            status: widget.ticket.status,
                            userId: widget.ticket.userId,
                            createdAt: widget.ticket.createdAt,
                          );

                          try {
                            await ticketController.modifierTicket(widget.ticket.id!, updatedTicket);
                            Navigator.pop(context, true);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur lors de la modification : $e')),
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
