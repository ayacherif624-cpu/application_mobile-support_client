import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des utilisateurs")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Card(
                child: ListTile(
                  title: Text(user['email']),
                  subtitle: Text("Rôle: ${user['role']}"),
                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)
                          .update({'role': value});
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'client', child: Text('Client')),
                      const PopupMenuItem(value: 'support', child: Text('Support')),
                      const PopupMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
