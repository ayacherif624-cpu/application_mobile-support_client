import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/ticket_controller.dart';
import '../models/ticket.dart';

class AdminTicketListView extends StatelessWidget {
  const AdminTicketListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TicketController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tous les tickets"),
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: controller.getTousLesTickets(), // ✅ EXISTE MAINTENANT
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun ticket"));
          }

          final tickets = snapshot.data!;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];

              return Card(
                child: ListTile(
                  title: Text(ticket.titre),
                  subtitle: Text("Statut : ${ticket.status}"),
                  trailing: const Icon(Icons.arrow_forward),

                  // ✅✅✅ NAVIGATION PARFAITEMENT CORRECTE
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/admin-priorites',
                      arguments: {
                        'ticket': ticket,           // ✅ TRANSMIS
                        'roleUtilisateur': 'admin', // ✅ TRANSMIS
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
