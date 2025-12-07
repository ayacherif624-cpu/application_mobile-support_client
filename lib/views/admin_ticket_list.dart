 import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTicketListView extends StatelessWidget {
  const AdminTicketListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Affectation des tickets")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, ticketSnapshot) {
          if (!ticketSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = ticketSnapshot.data!.docs;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(ticket['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Statut: ${ticket['status']}"),
                      Text("Priorité: ${ticket['priority']}"),
                      Text("Assigné à: ${ticket['assignedTo'] ?? 'Non affecté'}"),
                      const SizedBox(height: 8),

                      // ✅ DROPDOWN DES MEMBRES SUPPORT
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('role', isEqualTo: 'support')
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final supports = userSnapshot.data!.docs;

                          return DropdownButton<String>(
                            hint: const Text("Affecter à un membre"),
                            onChanged: (supportId) {
                              FirebaseFirestore.instance
                                  .collection('tickets')
                                  .doc(ticket.id)
                                  .update({
                                'assignedTo': supportId,
                                'status': 'en cours'
                              });
                            },
                            items: supports.map((support) {
                              return DropdownMenuItem(
                                value: support.id,
                                child: Text(support['nom']),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
