import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatelessWidget {
  final String userId;
  final String roleUtilisateur;

  const AdminDashboard({
    super.key,
    required this.userId,
    required this.roleUtilisateur,
  });

  // ✅ DÉCONNEXION + REDIRECTION LOGIN
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', // ✅ ta page de connexion
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (roleUtilisateur != 'admin') {
      return const Scaffold(
        body: Center(
          child: Text(
            "⛔ Accès refusé",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),

      // ✅ ✅ ✅ APPBAR AVEC BOUTON DÉCONNEXION
      appBar: AppBar(
        title: const Text("Dashboard Administrateur"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 6,
        actions: [
          TextButton.icon(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              "Déconnexion",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ HEADER ADMIN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.lightBlueAccent],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 36,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Bienvenue Administrateur",
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

            // ✅ DASHBOARD EN GRILLE
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _dashboardGridCard(
                  icon: Icons.confirmation_number,
                  title: "Tous les tickets",
                  subtitle: "Liste complète",
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/support-admin-tickets');
                  },
                ),
                _dashboardGridCard(
                  icon: Icons.assignment_ind,
                  title: "À affecter",
                  subtitle: "Sans agent",
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/tickets-a-affecter');
                  },
                ),
                _dashboardGridCard(
                  icon: Icons.bar_chart,
                  title: "Statistiques",
                  subtitle: "Analyse totale",
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, '/admin-stats');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ CARTE MODERNE
  Widget _dashboardGridCard({
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
