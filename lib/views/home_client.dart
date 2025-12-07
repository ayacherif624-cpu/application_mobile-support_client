import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_ticket_screen.dart';
import 'ticket_list_screen.dart';

class HomeClient extends StatefulWidget {
  @override
  _HomeClientState createState() => _HomeClientState();
}

class _HomeClientState extends State<HomeClient> {
  String userName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      setState(() {
        userName = doc['name'] ?? 'Client';
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil Client'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue, $userName !',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  // ✅ CREER TICKET
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Créer un nouveau ticket'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateTicketView(userId: user!.uid),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  // ✅ MES TICKETS
                  ElevatedButton.icon(
                    icon: Icon(Icons.list),
                    label: Text('Mes tickets'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListeTicketsView(
                            userId: user!.uid,      // ✅ UID CLIENT
                            roleUtilisateur: "client",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
