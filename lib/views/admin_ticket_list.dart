import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/ticket_controller.dart';
import '../models/ticket.dart';

class AdminTicketListView extends StatefulWidget {
  const AdminTicketListView({super.key});

  @override
  State<AdminTicketListView> createState() => _AdminTicketListViewState();
}

class _AdminTicketListViewState extends State<AdminTicketListView> {
  String? statutFiltre;
  String? categorieFiltre;
  String? utilisateurFiltre;
  DateTime? dateFiltre;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TicketController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tous les tickets"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _ouvrirFiltres,
          ),
        ],
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: controller.getTousLesTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun ticket"));
          }

          List<TicketModel> tickets = snapshot.data!;

          // ✅✅✅ FILTRAGE CORRIGÉ

          // ✅ FILTRE PAR STATUT
          if (statutFiltre != null && statutFiltre!.isNotEmpty) {
            tickets =
                tickets.where((t) => t.status == statutFiltre).toList();
          }

          // ✅ FILTRE PAR CATÉGORIE (INSENSIBLE À LA CASSE)
          if (categorieFiltre != null && categorieFiltre!.isNotEmpty) {
            tickets = tickets.where((t) =>
              t.categorie
                  .toLowerCase()
                  .contains(categorieFiltre!.toLowerCase())
            ).toList();
          }

          // ✅ FILTRE PAR UTILISATEUR (RECHERCHE PARTIELLE)
          if (utilisateurFiltre != null && utilisateurFiltre!.isNotEmpty) {
            tickets = tickets.where((t) =>
              t.userId
                  .toLowerCase()
                  .contains(utilisateurFiltre!.toLowerCase())
            ).toList();
          }

          // ✅ FILTRE PAR DATE
          if (dateFiltre != null) {
            tickets = tickets.where((t) {
              final d = t.createdAt;
              return d.year == dateFiltre!.year &&
                  d.month == dateFiltre!.month &&
                  d.day == dateFiltre!.day;
            }).toList();
          }

          if (tickets.isEmpty) {
            return const Center(
              child: Text("Aucun ticket selon les filtres"),
            );
          }

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];

              return Card(
                child: ListTile(
                  title: Text(ticket.titre),
                  subtitle: Text(
                    "Statut : ${ticket.status} | "
                    "Catégorie : ${ticket.categorie} | "
                    "Date : ${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}",
                  ),
                  trailing: const Icon(Icons.arrow_forward),

                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/admin-priorites',
                      arguments: {
                        'ticket': ticket,
                        'roleUtilisateur': 'admin',
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅✅✅ POPUP DE FILTRAGE CORRIGÉ
  void _ouvrirFiltres() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filtres",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // ✅ FILTRE STATUT (VALEURS EXACTES FIRESTORE)
              DropdownButtonFormField<String>(
                value: statutFiltre,
                hint: const Text("Filtrer par statut"),
                items: const [
                  DropdownMenuItem(value: 'Nouveau', child: Text("Nouveau")),
                  DropdownMenuItem(value: 'En cours', child: Text("En cours")),
                  DropdownMenuItem(value: 'Résolu', child: Text("Résolu")),
                ],
                onChanged: (value) {
                  setState(() => statutFiltre = value);
                },
              ),

              const SizedBox(height: 10),

              // ✅ FILTRE CATÉGORIE
              TextField(
                decoration: const InputDecoration(
                  labelText: "Filtrer par catégorie",
                ),
                onChanged: (value) {
                  setState(() => categorieFiltre = value);
                },
              ),

              const SizedBox(height: 10),

              // ✅ FILTRE UTILISATEUR
              TextField(
                decoration: const InputDecoration(
                  labelText: "Filtrer par utilisateur (userId)",
                ),
                onChanged: (value) {
                  setState(() => utilisateurFiltre = value);
                },
              ),

              const SizedBox(height: 10),

              // ✅ FILTRE DATE
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text("Filtrer par date"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                    initialDate: DateTime.now(),
                  );

                  if (picked != null) {
                    setState(() => dateFiltre = picked);
                  }
                },
              ),

              const SizedBox(height: 15),

              // ✅ RESET FILTRES
              TextButton(
                onPressed: () {
                  setState(() {
                    statutFiltre = null;
                    categorieFiltre = null;
                    utilisateurFiltre = null;
                    dateFiltre = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Réinitialiser les filtres"),
              ),
            ],
          ),
        );
      },
    );
  }
}
