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
      appBar: AppBar(
        title: const Text("Choisir un support"),
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
              child: Text("❌ Erreur de chargement des supports"),
            );
          }

          // ✅ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ DONNÉES VIDES
          if (snapshot.connectionState == ConnectionState.active &&
              (!snapshot.hasData || snapshot.data!.docs.isEmpty)) {
            return const Center(
              child: Text("Aucun agent support disponible"),
            );
          }

          final supports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: supports.length,
            itemBuilder: (context, index) {
              final support = supports[index];
              final data = support.data() as Map<String, dynamic>;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
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

                      const SizedBox(height: 6),

                      // ✅ EMAIL
                      Text("📧 Email : ${data['email'] ?? 'Non défini'}"),

                      // ✅ POSTE
                      Text("💼 Poste : ${data['Poste'] ?? 'Non défini'}"),

                      // ✅ DISPONIBILITÉ
                      Text(
                        "🟢 Urgence : ${data['Disponibilité d’urgence'] ?? 'Non définie'}",
                      ),

                      // ✅ HORAIRES
                      Text(
                        "⏰ Horaires : ${data['Horaires'] ?? 'Non définis'}",
                      ),

                      // ✅ JOURS DE TRAVAIL
                      Text(
                        "📅 Jours : ${data['Jours de travail'] ?? 'Non définis'}",
                      ),

                      const SizedBox(height: 10),

                      // ✅ BOUTON AFFECTER
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          child: const Text("Affecter"),
                          onPressed: () async {
                            try {
                              await controller.assignTicket(
                                ticketId: ticketId,
                                supportId: support.id,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "✅ Ticket affecté avec succès"),
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
}
