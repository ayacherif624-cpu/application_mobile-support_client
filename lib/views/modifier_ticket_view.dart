 import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/ticket_controller.dart';
import '../models/ticket_model.dart';

class ModifierTicketView extends StatefulWidget {
  final TicketModel ticket;
  const ModifierTicketView({super.key, required this.ticket});

  @override
  State<ModifierTicketView> createState() => _ModifierTicketViewState();
}

class _ModifierTicketViewState extends State<ModifierTicketView> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _priority;
  late String _category;
  late List<String> _attachments;

  late TicketController ticketController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    ticketController = Provider.of<TicketController>(context, listen: false);

    _titleController = TextEditingController(text: widget.ticket.title);
    _descriptionController = TextEditingController(text: widget.ticket.description);
    _priority = widget.ticket.priority;
    _category = widget.ticket.category;
    _attachments = List.from(widget.ticket.attachments);
  }

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() => _attachments.addAll(result.paths.whereType<String>()));
    }
  }

  void _updateTicket() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) return;
    setState(() => isLoading = true);

    TicketModel updatedTicket = TicketModel(
      id: widget.ticket.id,
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _priority,
      category: _category,
      attachments: _attachments,
      userId: widget.ticket.userId,
    );

    await ticketController.modifierTicket(updatedTicket.id!, updatedTicket);
    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le ticket'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce ticket ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTicket();
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteTicket() async {
    setState(() => isLoading = true);
    await ticketController.supprimerTicket(widget.ticket.id!);
    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier Ticket"),
        actions: [
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _showDeleteDialog)
        ],
      ),
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
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Titre",
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Description",
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _priority,
                  items: ['Faible', 'Moyenne', 'Haute']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _priority = val!),
                  decoration: InputDecoration(
                    labelText: "Priorité",
                    prefixIcon: const Icon(Icons.priority_high),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: ['Technique', 'Comptabilité', 'Autre']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _category = val!),
                  decoration: InputDecoration(
                    labelText: "Catégorie",
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Joindre des fichiers"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                _attachments.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _attachments
                            .map((f) => Card(
                                  color: Colors.blue.shade50,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: const Icon(Icons.insert_drive_file),
                                    title: Text(f.split('/').last),
                                  ),
                                ))
                            .toList(),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: isLoading ? null : _updateTicket,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text("Modifier Ticket", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
