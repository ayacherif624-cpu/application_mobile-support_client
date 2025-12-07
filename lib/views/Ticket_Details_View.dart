import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket.dart';

class DetailTicketAdminView extends StatelessWidget {
  final TicketModel ticket;
  final String roleUtilisateur;

  const DetailTicketAdminView({
    super.key,
    required this.ticket,
    required this.roleUtilisateur,
  });

  // ✅ FONCTION SÉCURISÉE POUR MODIFIER LA PRIORITÉ
  void _changerPriorite(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // ✅ Normalisation totale pour éviter les crashs
        String nouvellePriorite = ticket.priorite.toLowerCase();

        final List<String> priorites = ['faible', 'moyenne', 'haute'];

        // ✅ Sécurité si Firestore contient une valeur invalide
        if (!priorites.contains(nouvellePriorite)) {
          nouvellePriorite = 'moyenne';
        }

        return AlertDialog(
          title: const Text("Modifier la priorité"),
          content: DropdownButtonFormField<String>(
            value: nouvellePriorite,
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
      appBar: AppBar(
        title: const Text("Détails du ticket"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Titre : ${ticket.titre}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),

            Text("Description : ${ticket.description}"),
            const SizedBox(height: 8),

            Text("Statut : ${ticket.status}"),
            const SizedBox(height: 8),

            Text("Priorité : ${ticket.priorite}"),
            const SizedBox(height: 8),

            Text("Créé par : ${ticket.userId}"),
            const SizedBox(height: 8),

            Text("Rôle : $roleUtilisateur"),
            const SizedBox(height: 30),

            // ✅ BOUTON ADMIN 100% FONCTIONNEL
            if (roleUtilisateur == 'admin')
              ElevatedButton.icon(
                onPressed: () => _changerPriorite(context),
                icon: const Icon(Icons.edit),
                label: const Text("Modifier la priorité"),
              ),
          ],
        ),
      ),
    );
  }
}
