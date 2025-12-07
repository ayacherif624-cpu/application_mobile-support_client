import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketsAAffecterView extends StatelessWidget {
  const TicketsAAffecterView({super.key});

  Stream<QuerySnapshot> getTicketsNonAffectes() {
    return FirebaseFirestore.instance
        .collection('tickets')
        .where('assignerId', isNull: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),

      // ✅ APPBAR MODERNE
      appBar: AppBar(
        title: const Text("Tickets à affecter"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 6,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: getTicketsNonAffectes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucun ticket à affecter",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final data = ticket.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),

                  // ✅ TITRE
                  title: Text(
                    data['titre'] ?? 'Sans titre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // ✅ DESCRIPTION
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data['description'] ?? '',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // ✅ ICÔNE MODERNE
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey,
                  ),

                  // ✅ NAVIGATION
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/choisir-support',
                      arguments: ticket.id,
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
