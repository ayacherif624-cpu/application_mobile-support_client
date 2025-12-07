import 'package:flutter/material.dart';

class SupportDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Espace Support")),
      body: Column(
        children: [
          ListTile(title: Text("Voir tickets en attente")),
          ListTile(title: Text("Changer le statut")),
          ListTile(title: Text("Affecter un ticket")),
        ],
      ),
    );
  }
}
