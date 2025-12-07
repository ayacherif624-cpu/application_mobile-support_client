import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportHomeView extends StatelessWidget {
  final String userId;
  final String roleUtilisateur;

  const SupportHomeView({
    super.key,
    required this.userId,
    required this.roleUtilisateur,
  });

  // ✅ DÉCONNEXION AVEC CONFIRMATION
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
            child: const Text(
              "Déconnexion",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
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

        // ✅ ✅ ✅ BOUTON DÉCONNEXION PETIT DANS L’APPBAR
        actions: [
          TextButton.icon(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout, color: Colors.white, size: 18),
            label: const Text(
              "Déconnexion",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ HEADER SUPPORT
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
                    child: Icon(
                      Icons.support_agent,
                      size: 34,
                      color: Colors.blue,
                    ),
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

            // ✅ CARTES FONCTIONNALITÉS
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _dashboardCard(
                    icon: Icons.confirmation_number,
                    title: "Tickets à gérer",
                    subtitle: "Toutes les demandes",
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pushNamed(context, '/support-tickets');
                    },
                  ),
                  _dashboardCard(
                    icon: Icons.chat,
                    title: "Discussions",
                    subtitle: "Client ↔ Support",
                    color: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(context, '/support-chats');
                    },
                  ),
                  _dashboardCard(
                    icon: Icons.notifications_active,
                    title: "Notifications",
                    subtitle: "Réponses clients",
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Notifications bientôt disponibles"),
                        ),
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

  // ✅ CARTE MODERNE
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
