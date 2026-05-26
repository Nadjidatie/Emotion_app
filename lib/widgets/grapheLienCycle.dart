import 'package:emotion_app/model/cycle_phase.dart';
import 'package:emotion_app/services/statistiquesService.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// BarChart : score moyen par phase du cycle.
///
/// C'est le graphique "signature" du projet — il connecte explicitement
/// les humeurs au cycle menstruel, ce qui est l'idée centrale de l'app.
class GrapheLienCycle extends StatelessWidget {
  final List<StatsParPhase> stats;

  const GrapheLienCycle({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final phasesAvecDonnees = stats.where((s) => s.nbJours > 0).toList();
    if (phasesAvecDonnees.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Pas encore assez de données pour relier humeur et cycle.',
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

    // Phase championne (uniquement parmi celles qui ont des données).
    final triees = [...phasesAvecDonnees]
      ..sort((a, b) => b.scoreMoyen.compareTo(a.scoreMoyen));
    final championne = triees.first;
    final infoChamp = CyclePhaseInfo.of(championne.phase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 170,
          child: BarChart(
            BarChartData(
              maxY: 10,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2.5,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: const Color(0xFFE8DDF5),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value == 5 || value == 10) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF8B87A3),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= stats.length) {
                        return const SizedBox.shrink();
                      }
                      final phase = stats[i].phase;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _libelleCourt(phase),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8B87A3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      const Color(0xFF4C4A73).withOpacity(0.92),
                  getTooltipItem: (group, gIdx, rod, rIdx) {
                    final s = stats[gIdx];
                    final info = CyclePhaseInfo.of(s.phase);
                    return BarTooltipItem(
                      '${info.nom}\n${s.scoreMoyen.toStringAsFixed(1)}/10 · ${s.nbJours} j',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              barGroups: List.generate(stats.length, (i) {
                final s = stats[i];
                final info = CyclePhaseInfo.of(s.phase);
                final aDesDonnees = s.nbJours > 0;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: aDesDonnees ? s.scoreMoyen : 0.15,
                      color: aDesDonnees
                          ? info.couleur
                          : const Color(0xFFE8DDF5),
                      width: 26,
                      borderRadius: BorderRadius.circular(8),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 10,
                        color: const Color(0xFFF7F3FB),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: infoChamp.couleur.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(infoChamp.icone,
                  color: infoChamp.couleur, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'En moyenne, tu te sens mieux en ${infoChamp.nom.toLowerCase()} '
                  '(${championne.scoreMoyen.toStringAsFixed(1)}/10 sur ${championne.nbJours} jours).',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4C4A73),
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _libelleCourt(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruelle:
        return 'Règles';
      case CyclePhase.folliculaire:
        return 'Follic.';
      case CyclePhase.ovulatoire:
        return 'Ovul.';
      case CyclePhase.luteale:
        return 'Lutéale';
    }
  }
}
