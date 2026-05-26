import 'package:emotion_app/services/statistiquesService.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Donut + légende de la répartition des humeurs sur la période.
class GrapheRepartitionHumeurs extends StatelessWidget {
  final List<TrancheHumeur> tranches;

  const GrapheRepartitionHumeurs({super.key, required this.tranches});

  @override
  Widget build(BuildContext context) {
    if (tranches.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Pas encore d\'humeurs sélectionnées sur cette période.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8B87A3),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    final top = tranches.first;

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Donut + % centré.
          SizedBox(
            width: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 38,
                    startDegreeOffset: -90,
                    sections: tranches.map((t) {
                      final couleur =
                          t.option?.couleur ?? const Color(0xFFBDB6CF);
                      return PieChartSectionData(
                        value: t.compte.toDouble(),
                        color: couleur,
                        radius: 26,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${top.pourcentage.round()}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4C4A73),
                      ),
                    ),
                    Text(
                      top.libelle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8B87A3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Légende.
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tranches
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: t.option?.couleur ??
                                  const Color(0xFFBDB6CF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.libelle,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4C4A73),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${t.pourcentage.round()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B87A3),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
