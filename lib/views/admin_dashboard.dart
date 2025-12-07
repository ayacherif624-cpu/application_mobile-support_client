import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final String userId;
  final String roleUtilisateur;

  const AdminDashboard({
    super.key,
    required this.userId,
    required this.roleUtilisateur,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Administrateur"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ INFOS ADMIN
            Text(
              "ID : $userId",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              "Rôle : $roleUtilisateur",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // ✅ BOUTON 1 — TOUS LES TICKETS
            Card(
              child: ListTile(
                leading: const Icon(Icons.confirmation_number),
                title: const Text("Tous les tickets"),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/support-admin-tickets',
                  );
                },
              ),
            ),

            // ✅ ✅ NOUVEAU — TICKETS NON AFFECTÉS
            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment_ind),
                title: const Text("Tickets à affecter"),
                subtitle: const Text("Tickets sans agent assigné"),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/tickets-a-affecter',
                  );
                },
              ),
            ),

            // ✅ BOUTON 2 — GESTION DES UTILISATEURS
            Card(
              child: ListTile(
                leading: const Icon(Icons.people),
                title: const Text("Gestion des utilisateurs"),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/users-management',
                  );
                },
              ),
            ),

            // ✅ BOUTON 3 — STATISTIQUES
            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text("Statistiques"),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/admin-stats',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
