 import 'package:flutter/material.dart';

class SupportHomeView extends StatelessWidget {
  const SupportHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil Support')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Bienvenue Support !',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Text('Vous pouvez gérer et résoudre les tickets.'),
          ],
        ),
      ),
    );
  }
}
