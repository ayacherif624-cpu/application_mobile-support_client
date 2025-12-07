import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatsView extends StatelessWidget {
  const AdminStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),

      appBar: AppBar(
        title: const Text("Statistiques Admin"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 6,
      ),

      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('tickets').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucune donnée disponible"));
          }

          final docs = snapshot.data!.docs;

          final Map<String, int> statutCount = {};
          final Map<String, int> categorieCount = {};

          double totalTempsResolution = 0;
          int ticketsResolus = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final String statut = data['status'];
            final String categorie = data['categorie'];
            final Timestamp createdAt = data['createdAt'];

            statutCount[statut] = (statutCount[statut] ?? 0) + 1;
            categorieCount[categorie] =
                (categorieCount[categorie] ?? 0) + 1;

            if (statut.toLowerCase() == 'résolu' &&
                data.containsKey('resolvedAt')) {
              final Timestamp resolvedAt = data['resolvedAt'];
              final duration =
                  resolvedAt.toDate().difference(createdAt.toDate()).inHours;
              totalTempsResolution += duration;
              ticketsResolus++;
            }
          }

          final double tempsMoyen = ticketsResolus == 0
              ? 0
              : totalTempsResolution / ticketsResolus;

          return Scrollbar(
            thumbVisibility: true,
            interactive: true,
            radius: const Radius.circular(20),
            thickness: 8,

            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ✅ KPI
                  Row(
                    children: [
                      _kpiCard(
                        title: "Total Tickets",
                        value: docs.length.toString(),
                        icon: Icons.confirmation_number,
                        color: Colors.indigo,
                      ),
                      const SizedBox(width: 12),
                      _kpiCard(
                        title: "Temps moyen (h)",
                        value: tempsMoyen.toStringAsFixed(1),
                        icon: Icons.timer,
                        color: Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ✅ PIE CHART STATUT
                  _sectionTitle("Tickets par statut"),

                  SizedBox(
                    height: 260,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 35,
                        sectionsSpace: 4,
                        sections: statutCount.entries.map((entry) {
                          return PieChartSectionData(
                            value: entry.value.toDouble(),
                            title: "${entry.key}\n${entry.value}",
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ✅ BAR CHART CATÉGORIE DETAILLÉ
                  _sectionTitle("Tickets par type de problème"),

                  SizedBox(
                    height: 350,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,

                        maxY: categorieCount.values
                                .reduce((a, b) => a > b ? a : b)
                                .toDouble() +
                            2,

                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            
                            getTooltipItem:
                                (group, groupIndex, rod, rodIndex) {
                              final category = categorieCount.keys
                                  .elementAt(group.x.toInt());
                              return BarTooltipItem(
                                "$category\n${rod.toY.toInt()} tickets",
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),

                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 35,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < categorieCount.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      categorieCount.keys.elementAt(index),
                                      style:
                                          const TextStyle(fontSize: 11),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),

                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),

                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey.shade300),
                        ),

                        barGroups: categorieCount.entries
                            .toList()
                            .asMap()
                            .entries
                            .map(
                          (entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.value.toDouble(),
                                  width: 22,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                              ],
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ KPI CARD
  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ TITRE DE SECTION
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
