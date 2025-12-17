 import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class SupportHomeView extends StatefulWidget {
  final String userId;            // ID du support connecté
  final String roleUtilisateur;   // Rôle : support / client

  const SupportHomeView({
    super.key,
    required this.userId,
    required this.roleUtilisateur,
  });

  @override
  State<SupportHomeView> createState() => _SupportHomeViewState();
}

class _SupportHomeViewState extends State<SupportHomeView> {
  @override
  void initState() {
    super.initState();
    _listenNewMessages(widget.userId); // notifications automatiques
  }

  /// Écoute les nouveaux messages clients et déclenche les notifications
  void _listenNewMessages(String supportId) {
    FirebaseFirestore.instance
        .collection('tickets')
        .where('assignerId', isEqualTo: supportId)
        .snapshots()
        .listen((ticketsSnapshot) {
      for (var ticketDoc in ticketsSnapshot.docs) {
        FirebaseFirestore.instance
            .collection('tickets')
            .doc(ticketDoc.id)
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .snapshots()
            .listen((messageSnapshot) {
          if (messageSnapshot.docs.isEmpty) return;

          final messageData = messageSnapshot.docs.first.data();
          final senderRole = messageData['senderRole'] ?? '';
          final seenBy = List<String>.from(messageData['seenBy'] ?? []);

          // Nouveau message client non lu
          if (senderRole == 'client' && !seenBy.contains(supportId)) {
            NotificationService.showNotification(
              title: "Nouveau message client",
              body: messageData['text'] ?? '',
            );

            // Marquer comme lu côté support pour ne pas renvoyer notification
            messageSnapshot.docs.first.reference.update({
              'seenBy': FieldValue.arrayUnion([supportId])
            });
          }
        });
      }
    });
  }

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        title: const Text("Espace Support"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        actions: [
          TextButton.icon(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout, color: Colors.white, size: 18),
            label: const Text("⬅️Déconnexion", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header support
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.lightBlueAccent],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.support_agent, size: 34, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Bienvenue, Support",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  // Tickets à gérer
                  _dashboardCard(
                    icon: Icons.confirmation_number,
                    title: "Tickets à gérer",
                    subtitle: "Toutes les demandes",
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/SupportTicketsView',
                        arguments: {"supportId": widget.userId},
                      );
                    },
                  ),
                  // Discussions
                  _dashboardCard(
                    icon: Icons.chat,
                    title: "Discussions",
                    subtitle: "Client ↔ Support",
                    color: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/support-chats',
                        arguments: {"supportId": widget.userId},
                      );
                    },
                  ),
                  // Notifications via bouton
                  _dashboardCard(
                    icon: Icons.notifications_active,
                    title: "Notifications",
                    subtitle: "Réponses clients",
                    color: Colors.orange,
                    onTap: () async {
                      // Vérifier les messages non lus
                      final ticketsSnapshot = await FirebaseFirestore.instance
                          .collection('tickets')
                          .where('assignerId', isEqualTo: widget.userId)
                          .get();

                      for (var ticketDoc in ticketsSnapshot.docs) {
                        final messagesSnapshot = await FirebaseFirestore.instance
                            .collection('tickets')
                            .doc(ticketDoc.id)
                            .collection('messages')
                            .orderBy('createdAt', descending: true)
                            .get();

                        for (var msgDoc in messagesSnapshot.docs) {
                          final msgData = msgDoc.data();
                          final senderRole = msgData['senderRole'] ?? '';
                          final seenBy = List<String>.from(msgData['seenBy'] ?? []);

                          if (senderRole == 'client' && !seenBy.contains(widget.userId)) {
                            NotificationService.showNotification(
                              title: "Nouveau message client",
                              body: msgData['text'] ?? '',
                            );
                            await msgDoc.reference.update({
                              'seenBy': FieldValue.arrayUnion([widget.userId])
                            });
                          }
                        }
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Notifications envoyées !")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
