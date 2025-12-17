import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

/// ===============================================
///     LISTE DES TICKETS ASSIGNÉS À UN SUPPORT
/// ===============================================

class SupportTicketsView extends StatelessWidget {
  final String supportId;

  const SupportTicketsView({super.key, required this.supportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tickets assignés"),
        backgroundColor: Colors.blue,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("tickets")
            .where("assignerId", isEqualTo: supportId)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun ticket assigné."));
          }

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final doc = tickets[index];
              final data = doc.data() as Map<String, dynamic>?;

              if (data == null) return const SizedBox();

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(data["titre"] ?? "Sans titre"),
                  subtitle: Text(data["description"] ?? "Aucune description"),
                  trailing: _statusBadge(data["status"] ?? "En cours"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SupportTicketDetailView(ticketId: doc.id),
                      ),
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

  /// Badge couleur pour les statuts
  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "En cours":
        color = Colors.orange;
        break;
      case "Résolu":
        color = Colors.green;
        break;
      case "Fermé":
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/// ===============================================
///       DÉTAIL D’UN TICKET + STATUT + PJ
/// ===============================================

class SupportTicketDetailView extends StatelessWidget {
  final String ticketId;

  const SupportTicketDetailView({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du ticket"),
        backgroundColor: Colors.blue,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("tickets")
            .doc(ticketId)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("Données indisponibles."));
          }

          final createdAt = data["createdAt"] is Timestamp
              ? (data["createdAt"] as Timestamp).toDate()
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// TITRE
                Text(
                  data["titre"] ?? "",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                /// DESCRIPTION
                Text(
                  data["description"] ?? "",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                /// STATUT
                _statusBadge(data["status"] ?? "En cours"),

                const SizedBox(height: 20),

                /// DATE
                Text(
                  "Créé le : ${createdAt ?? "Non disponible"}",
                  style: const TextStyle(fontSize: 15),
                ),

                const SizedBox(height: 20),

                /// UTILISATEUR
                Text("Créé par : ${data["userId"] ?? "Inconnu"}",
                    style: const TextStyle(fontSize: 15)),

                const SizedBox(height: 10),

                Text("Assigné à : ${data["assignerId"] ?? "Non assigné"}",
                    style: const TextStyle(fontSize: 15)),

                const SizedBox(height: 30),

                /// PIÈCE JOINTE
                if (data["attachmentUrl"] != null)
                  _attachmentSection(data["attachmentUrl"]),

                const SizedBox(height: 30),

                const Text(
                  "Changer le statut du ticket",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                _statusButton("En cours", Colors.orange),
                _statusButton("Résolu", Colors.green),
                _statusButton("Fermé", Colors.red),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Bouton de changement de statut
  Widget _statusButton(String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 45),
        ),
        onPressed: () {
          FirebaseFirestore.instance
              .collection("tickets")
              .doc(ticketId)
              .update({"status": status});
        },
        child: Text(
          "Marquer comme $status",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// Badge couleur en détail
  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "En cours":
        color = Colors.orange;
        break;
      case "Résolu":
        color = Colors.green;
        break;
      case "Fermé":
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  /// Pièce jointe
  Widget _attachmentSection(String url) {
    final isImage = url.endsWith(".png") ||
        url.endsWith(".jpg") ||
        url.endsWith(".jpeg") ||
        url.endsWith(".gif");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pièce jointe :",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        if (isImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: () async {
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.attach_file, color: Colors.white),
            label: const Text("Ouvrir le fichier"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
            ),
          ),
      ],
    );
  }
}
