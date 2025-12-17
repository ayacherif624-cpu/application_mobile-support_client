 import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase/views/chat_view.dart';

class SupportChatsView extends StatelessWidget {
  final String supportId;

  const SupportChatsView({super.key, required this.supportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discussions Support"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("tickets")
            .where("assignerId", isEqualTo: supportId)
            .orderBy("lastMessageTime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Gestion des erreurs
          if (snapshot.hasError) {
            return Center(
              child: Text("Erreur Firestore: ${snapshot.error}"),
            );
          }

          // Loader tant que les données n'arrivent pas
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data!.docs;

          // Debug console
          print("Nombre de tickets récupérés: ${tickets.length}");
          for (var doc in tickets) {
            print("Ticket: ${doc.id}, lastMessage: ${doc["lastMessage"]}");
          }

          if (tickets.isEmpty) {
            return const Center(
              child: Text("Aucune conversation trouvée."),
            );
          }

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final doc = tickets[index];
              final ticketId = doc.id;
              final lastMessage = doc["lastMessage"] ?? "Aucun message";
              final unread = doc["support_unread"] ?? 0;

              return ListTile(
                title: Text("Ticket : $ticketId"),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: unread > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Text(
                          unread.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
                onTap: () async {
                  // Remettre à zéro les messages non lus pour le support
                  await FirebaseFirestore.instance
                      .collection("tickets")
                      .doc(ticketId)
                      .update({"support_unread": 0});

                  // Ouvrir le chat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatView(
                        ticketId: ticketId,
                        currentUserId: supportId,
                        userRole: "support",
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
