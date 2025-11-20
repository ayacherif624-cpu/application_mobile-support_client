 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/ticket_controller.dart';
import '../models/ticket_model.dart';
import 'modifier_ticket_view.dart';
import 'create_ticket_view.dart';

class ListeTicketsView extends StatelessWidget {
  final String userId;
  const ListeTicketsView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ticketController = Provider.of<TicketController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateTicketView(userId: userId)),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: ticketController.getTicketsParUtilisateur(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) return const Center(child: Text('Aucun ticket trouvé'));

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return TicketTile(ticket: ticket);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateTicketView(userId: userId)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TicketTile extends StatelessWidget {
  final TicketModel ticket;
  const TicketTile({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final ticketController = Provider.of<TicketController>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(ticket.title),
        subtitle: Text('Priorité: ${ticket.priority} | Catégorie: ${ticket.category}'),
        trailing: PopupMenuButton(
          onSelected: (value) async {
            switch (value) {
              case 'modifier':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModifierTicketView(ticket: ticket),
                  ),
                );
                break;
              case 'supprimer':
                _showDeleteDialog(context, ticketController, ticket.id!);
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'modifier', child: Text('Modifier')),
            PopupMenuItem(value: 'supprimer', child: Text('Supprimer')),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TicketController controller, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce ticket ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.supprimerTicket(id);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ticket supprimé avec succès')));
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
