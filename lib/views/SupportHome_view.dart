 import 'package:flutter/material.dart';

class SupportHomeView extends StatelessWidget {
  final String userId;
  final String roleUtilisateur;

  const SupportHomeView({
    super.key,
    required this.userId,
    required this.roleUtilisateur,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil Support')),
      body: Center(
        child: Text(
          'Bienvenue Support !\nID: $userId\nRôle: $roleUtilisateur',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
