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

            // ✅ MENU ADMIN
            Card(
              child: ListTile(
                leading: const Icon(Icons.confirmation_number),
                title: const Text("Tous les tickets"),
                onTap: () {
                  Navigator.pushNamed(context, '/tickets');
                },
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.people),
                title: const Text("Gestion des utilisateurs"),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text("Statistiques"),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
