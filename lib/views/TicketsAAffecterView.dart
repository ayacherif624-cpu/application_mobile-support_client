import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketsAAffecterView extends StatelessWidget {
  const TicketsAAffecterView({super.key}); // ✅ PLUS DE PARAMÈTRE ICI

  Stream<QuerySnapshot> getTicketsNonAffectes() {
    return FirebaseFirestore.instance
        .collection('tickets')
        .where('assignerId', isNull: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tickets à affecter")),
      body: StreamBuilder<QuerySnapshot>(
        stream: getTicketsNonAffectes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun ticket à affecter"));
          }

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final data = ticket.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['titre'] ?? 'Sans titre'),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/choisir-support', // ✅ REDIRECTION CORRECTE
                      arguments: ticket.id, // ✅ ON ENVOIE L’ID
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
