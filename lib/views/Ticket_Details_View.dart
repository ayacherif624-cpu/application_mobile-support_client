import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';

class DetailTicketAdminView extends StatelessWidget {
  final TicketModel ticket;
  final String roleUtilisateur;

  const DetailTicketAdminView({
    super.key,
    required this.ticket,
    required this.roleUtilisateur,
  });

  // ✅ DIALOG MODERNE POUR CHANGER LA PRIORITÉ
  void _changerPriorite(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String nouvellePriorite = ticket.priorite.toLowerCase();
        final List<String> priorites = ['faible', 'moyenne', 'haute'];

        if (!priorites.contains(nouvellePriorite)) {
          nouvellePriorite = 'moyenne';
        }

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text("Modifier la priorité"),
          content: DropdownButtonFormField<String>(
            value: nouvellePriorite,
            decoration: const InputDecoration(
              labelText: "Priorité",
              border: OutlineInputBorder(),
            ),
            items: priorites.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text(p.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                nouvellePriorite = value;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('tickets')
                    .doc(ticket.id)
                    .update({
                  'priorite': nouvellePriorite,
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("✅ Priorité modifiée avec succès"),
                  ),
                );
              },
              child: const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),

      // ✅ APPBAR MODERNE
      appBar: AppBar(
        title: const Text("Détails du ticket"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 6,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ CARTE PRINCIPALE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoLigne("Titre", ticket.titre),
                  _infoLigne("Description", ticket.description),
                  _infoLigne("Statut", ticket.status),
                  _infoLigne("Priorité", ticket.priorite),
                  _infoLigne("Créé par", ticket.userId),
                  _infoLigne("Rôle", roleUtilisateur),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ✅ BOUTON ADMIN
            if (roleUtilisateur == 'admin')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _changerPriorite(context),
                  icon: const Icon(Icons.edit),
                  label: const Text("Modifier la priorité"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ LIGNE D'INFOS MODERNE
  Widget _infoLigne(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
