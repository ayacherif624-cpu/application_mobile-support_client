import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/ticket_controller.dart';
import '../models/ticket.dart';
import 'create_ticket_screen.dart';
import 'modifier_ticket_view.dart';
import 'chat_view.dart';

class ListeTicketsView extends StatelessWidget {
  final String userId;
  final String roleUtilisateur;

  const ListeTicketsView({
    super.key,
    required this.userId,
    required this.roleUtilisateur,
  });

  @override
  Widget build(BuildContext context) {
    final ticketController = Provider.of<TicketController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Tickets')),
      body: SafeArea(
        child: StreamBuilder<List<TicketModel>>(
          stream: ticketController.getTicketsParUtilisateur(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            final tickets = snapshot.data ?? [];

            if (tickets.isEmpty) {
              return const Center(child: Text('Aucun ticket trouvé'));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                final statutText = ticket.status;
                final statutColor = _getStatusColor(statutText);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text(
                      ticket.titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    leading: Chip(
                      label: Text(
                        statutText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: statutColor,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoText("Description", ticket.description),
                            _buildInfoText(
                              "Assigné à",
                              ticket.assignerId ?? "Non assigné",
                            ),
                            _buildInfoText(
                              "Date",
                              ticket.createdAt.toLocal().toString(),
                            ),

                            const SizedBox(height: 10),

                            // ✅ ✅ ✅ AFFICHAGE DES PIÈCES JOINTES (CORRIGÉ)
                            if (ticket.attachments.isNotEmpty) ...[
                              const Text(
                                "Pièces jointes :",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                children: ticket.attachments.map((url) {
                                  final isImage = url.endsWith(".jpg") ||
                                      url.endsWith(".png") ||
                                      url.endsWith(".jpeg") ||
                                      url.endsWith(".webp");

                                  return ActionChip(
                                    avatar: Icon(
                                      isImage
                                          ? Icons.image
                                          : Icons.insert_drive_file,
                                    ),
                                    label: const Text("Ouvrir"),
                                    onPressed: () async {
                                      try {
                                        final uri = Uri.parse(url);
                                        if (!await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        )) {
                                          throw "Impossible d'ouvrir le lien";
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Erreur lors de l'ouverture du fichier",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ],

                            const SizedBox(height: 12),

                            // ✅ ✅ ✅ BOUTONS ACTIONS
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildActionButton(
                                  icon: Icons.edit,
                                  color: Colors.blue,
                                  label: "Modifier",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ModifierTicketView(
                                          ticket: ticket,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.delete,
                                  color: Colors.red,
                                  label: "Supprimer",
                                  onPressed: () async {
                                    final confirm =
                                        await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                            "Confirmer la suppression"),
                                        content: const Text(
                                            "Voulez-vous vraiment supprimer ce ticket ?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Annuler"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              "Supprimer",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await ticketController
                                          .supprimerTicket(ticket.id!);
                                    }
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.chat,
                                  color: Colors.green,
                                  label: "Discussion",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatView(
                                          ticketId: ticket.id!,
                                          currentUserId: userId,
                                          userType: roleUtilisateur,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      // ✅ BOUTON AJOUT
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateTicketView(userId: userId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ✅ Couleur selon statut
  Color _getStatusColor(String status) {
    switch (status) {
      case "Nouveau":
        return Colors.blue;
      case "En cours":
        return Colors.orange;
      case "Résolu":
        return Colors.green;
      case "Fermé":
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // ✅ Affichage texte
  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        "$label : $value",
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  // ✅ Boutons actions
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 14),
      ),
    );
  }
}
