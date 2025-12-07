import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStatsView extends StatelessWidget {
  const AdminStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques")),
      body: FutureBuilder(
        future: Future.wait([
          FirebaseFirestore.instance.collection('tickets').get(),
          FirebaseFirestore.instance.collection('users').get(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data![0].docs.length;
          final users = snapshot.data![1].docs.length;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: const Text("Nombre total de tickets"),
                    trailing: Text(tickets.toString()),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text("Nombre total d'utilisateurs"),
                    trailing: Text(users.toString()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
