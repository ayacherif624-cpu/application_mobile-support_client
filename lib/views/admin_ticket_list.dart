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
      backgroundColor: const Color(0xFFF4F7FF),

      // ✅ APPBAR MODERNE
      appBar: AppBar(
        title: const Text("Tous les tickets"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 6,
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

          // ✅ FILTRAGE
          if (statutFiltre != null && statutFiltre!.isNotEmpty) {
            tickets =
                tickets.where((t) => t.status == statutFiltre).toList();
          }

          if (categorieFiltre != null && categorieFiltre!.isNotEmpty) {
            tickets = tickets
                .where((t) => t.categorie
                    .toLowerCase()
                    .contains(categorieFiltre!.toLowerCase()))
                .toList();
          }

          if (utilisateurFiltre != null &&
              utilisateurFiltre!.isNotEmpty) {
            tickets = tickets
                .where((t) => t.userId
                    .toLowerCase()
                    .contains(utilisateurFiltre!.toLowerCase()))
                .toList();
          }

          if (dateFiltre != null) {
            tickets = tickets.where((t) {
              final d = t.createdAt;
              return d.year == dateFiltre!.year &&
                  d.month == dateFiltre!.month &&
                  d.day == dateFiltre!.day;
            }).toList();
          }

          if (tickets.isEmpty) {
            return const Center(child: Text("Aucun ticket selon les filtres"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),

                  title: Text(
                    ticket.titre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statutBadge(ticket.status),
                        const SizedBox(height: 6),
                        Text("Catégorie : ${ticket.categorie}"),
                        Text(
                          "Date : ${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  trailing:
                      const Icon(Icons.arrow_forward_ios, size: 18),

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

  // ✅ BADGE STATUT MODERNE
  Widget _statutBadge(String statut) {
    Color color;

    switch (statut) {
      case 'Nouveau':
        color = Colors.blue;
        break;
      case 'En cours':
        color = Colors.orange;
        break;
      case 'Résolu':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statut,
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // ✅ ✅ ✅ FILTRES MODERNES (UI SEULEMENT)
  void _ouvrirFiltres() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Filtres avancés",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                const Text("Statut",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: statutFiltre,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  hint: const Text("Choisir un statut"),
                  items: const [
                    DropdownMenuItem(
                        value: 'Nouveau', child: Text("Nouveau")),
                    DropdownMenuItem(
                        value: 'En cours', child: Text("En cours")),
                    DropdownMenuItem(
                        value: 'Résolu', child: Text("Résolu")),
                  ],
                  onChanged: (value) {
                    setState(() => statutFiltre = value);
                  },
                ),

                const SizedBox(height: 18),

                const Text("Catégorie",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Ex: Bug, Réseau...",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => categorieFiltre = value,
                ),

                const SizedBox(height: 18),

                const Text("Utilisateur",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                TextField(
                  decoration: InputDecoration(
                    hintText: "ID utilisateur",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => utilisateurFiltre = value,
                ),

                const SizedBox(height: 18),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.date_range),
                  label: const Text("Choisir une date"),
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

                const SizedBox(height: 26),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            statutFiltre = null;
                            categorieFiltre = null;
                            utilisateurFiltre = null;
                            dateFiltre = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Réinitialiser"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700),
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text("Appliquer"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
