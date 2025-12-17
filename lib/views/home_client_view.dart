import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_ticket_view.dart';
import 'ticket_list_view.dart';

class HomeClient extends StatefulWidget {
  const HomeClient({super.key});

  @override
  State<HomeClient> createState() => _HomeClientState();
}

class _HomeClientState extends State<HomeClient> {
  String userName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // ✅ RÉCUPÉRATION DU NOM UTILISATEUR
  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userName = doc.data()?['name'] ?? 'Client';
        isLoading = false;
      });
    }
  }

  // ✅ DÉCONNEXION + REDIRECTION LOGIN
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Column(
                  children: [
                    // ✅ HEADER
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 15),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Bienvenue 👋",
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // ✅ ✅ ✅ BOUTON DÉCONNEXION PETIT (SANS ROUGE)
                          TextButton.icon(
                            onPressed: logout,
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              "Déconnexion",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ✅ CONTAINER BLANC PRINCIPAL
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          children: [
                            // ✅ BOUTON CRÉER TICKET
                            _modernCardButton(
                              icon: Icons.add_circle_outline,
                              title: "Créer un ticket",
                              subtitle: "Envoyer une nouvelle demande",
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CreateTicketView(userId: user!.uid),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // ✅ BOUTON MES TICKETS
                            _modernCardButton(
                              icon: Icons.list_alt,
                              title: "Mes tickets",
                              subtitle: "Consulter mes demandes",
                              color: Colors.indigo,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ListeTicketsView(
                                      userId: user!.uid,
                                      roleUtilisateur: "client",
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ✅ BOUTON MODERNE
  Widget _modernCardButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withOpacity(0.1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 15),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
