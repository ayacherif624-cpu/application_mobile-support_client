import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      resizeToAvoidBottomInset: true,
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
                final statutText = ticket.status ?? "Nouveau";
                final statutColor = _getStatusColor(statutText);
                final attachments = ticket.attachments ?? [];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text(
                      ticket.title ?? "Titre inconnu",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    leading: Chip(
                      label: Text(
                        statutText,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                            _buildInfoText("Priorité", ticket.priority),
                            _buildInfoText("Catégorie", ticket.category),
                            const SizedBox(height: 8),

                            // Images
                            if (attachments.isNotEmpty)
                              SizedBox(
                                height: 120,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: attachments.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, imgIndex) {
                                    final imgUrl = attachments[imgIndex];
                                    return Image.network(
                                      imgUrl,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[300],
                                        child:
                                            const Icon(Icons.broken_image),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 12),

                            // Boutons
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  _buildActionButton(
                                    context,
                                    icon: Icons.edit,
                                    color: Colors.blue,
                                    label: "Modifier",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ModifierTicketView(ticket: ticket),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildActionButton(
                                    context,
                                    icon: Icons.delete,
                                    color: Colors.red,
                                    label: "Supprimer",
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
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
                                                child: const Text("Annuler")),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, true),
                                                child: const Text(
                                                  "Supprimer",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                )),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && ticket.id != null) {
                                        ticketController.supprimerTicket(ticket.id!);
                                      }
                                    },
                                  ),
                                  _buildActionButton(
                                    context,
                                    icon: Icons.chat,
                                    color: Colors.green,
                                    label: "Discussion",
                                    onPressed: () {
                                      if (ticket.id != null) {
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
                                      }
                                    },
                                  ),
                                ],
                              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CreateTicketView(userId: userId)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Couleur selon statut
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

  // Affichage info texte
  Widget _buildInfoText(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        "$label: ${value ?? 'Non définie'}",
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  // Boutons
  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required Color color,
      required String label,
      required VoidCallback onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18),
      label: Text(label, style: TextStyle(color: color, fontSize: 14)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
