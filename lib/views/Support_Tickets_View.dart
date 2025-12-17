import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketsView extends StatelessWidget {
  final String supportId; // l’ID du support connecté

  const SupportTicketsView({
    super.key,
    required this.supportId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),

      appBar: AppBar(
        title: const Text("Mes Tickets"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('assignerId', isEqualTo: supportId)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("❌ Erreur lors du chargement"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucun ticket à gérer",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            );
          }

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final doc = tickets[index];
              final data = doc.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['titre'] ?? "Sans titre",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      data['description'] ?? "Pas de description",
                      style: const TextStyle(fontSize: 14),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "📌 Priorité : ${data['priorite']}",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            data['status'] ?? "En cours",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
