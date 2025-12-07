 import 'package:flutter/material.dart';

class AdminDashboardView extends StatelessWidget {
  final String userId;
  final String roleUtilisateur;

  const AdminDashboardView({
    super.key,
    required this.userId,
    required this.roleUtilisateur,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord Admin')),
      body: Center(
        child: Text(
          'Bienvenue Admin !\nID: $userId\nRôle: $roleUtilisateur',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
