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
    // ✅ Sécurité UI : seul l’admin peut voir ce dashboard
    if (roleUtilisateur != 'admin') {
      return const Scaffold(
        body: Center(
          child: Text("⛔ Accès refusé"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Administrateur"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ✅ INFOS ADMIN
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text("ID : $userId"),
                subtitle: Text("Rôle : $roleUtilisateur"),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ TOUS LES TICKETS
            Card(
              child: ListTile(
                leading: const Icon(Icons.confirmation_number),
                title: const Text("Tous les tickets"),
                subtitle: const Text("Consulter tous les tickets"),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/support-admin-tickets',
                  );
                },
              ),
            ),

            // ✅ TICKETS NON AFFECTÉS
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

            // ✅ ✅ NOUVEAU — GESTION DES PRIORITÉS
            Card(
              child: ListTile(
                leading: const Icon(Icons.priority_high),
                title: const Text("Gestion des priorités"),
                subtitle: const Text("Modifier la priorité des tickets"),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/admin-priorites', // ✅ nouvelle route
                  );
                },
              ),
            ),

            // ✅ STATISTIQUES
            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text("Statistiques"),
                subtitle: const Text("Analyse des performances"),
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
