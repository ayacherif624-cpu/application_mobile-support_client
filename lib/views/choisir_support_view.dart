import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/ticket_controller.dart';

class ChoisirSupportView extends StatelessWidget {
  const ChoisirSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final String ticketId =
        ModalRoute.of(context)!.settings.arguments as String;

    final controller = Provider.of<TicketController>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),

      // ✅ APPBAR MODERNE
      appBar: AppBar(
        title: const Text("Choisir un support"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 6,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'support')
            .snapshots(),
        builder: (context, snapshot) {

          // ✅ ERREUR FIRESTORE
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "❌ Erreur de chargement des supports",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // ✅ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ LISTE VIDE
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucun agent support disponible",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final supports = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: supports.length,
            itemBuilder: (context, index) {
              final support = supports[index];
              final data = support.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ NOM
                      Text(
                        data['name'] ?? 'Sans nom',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 8),

                      _infoLigne("📧", "Email", data['email']),
                      _infoLigne("💼", "Poste", data['Poste']),
                      _infoLigne("🟢", "Urgence", data['Disponibilité d’urgence']),
                      _infoLigne("⏰", "Horaires", data['Horaires']),
                      _infoLigne("📅", "Jours", data['Jours de travail']),

                      const SizedBox(height: 14),

                      // ✅ BOUTON AFFECTER MODERNE
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.assignment_turned_in),
                          label: const Text("Affecter"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              await controller.assignTicket(
                                ticketId: ticketId,
                                supportId: support.id,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("✅ Ticket affecté avec succès"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "❌ Erreur lors de l'affectation"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
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

  // ✅ LIGNE D’INFO UI PROPRE
  Widget _infoLigne(String emoji, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        "$emoji $label : ${value ?? 'Non défini'}",
        style: const TextStyle(fontSize: 13.5),
      ),
    );
  }
}
