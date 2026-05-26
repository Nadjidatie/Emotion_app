import 'package:emotion_app/model/journalQuotidien.dart';
import 'package:emotion_app/services/statistiquesService.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Courbe d'évolution du score quotidien sur la période sélectionnée.
///
/// - Une entrée par jour de la période (manque = trou)
/// - Chaque point est colorié avec [JournalQuotidien.couleurDuJour]
/// - Une bande dégradée violette sous la courbe pour le côté "Flo"
class GrapheEvolutionScore extends StatelessWidget {
  final List<JournalQuotidien> logs;
  final PeriodeStats periode;

  const GrapheEvolutionScore({
    super.key,
    required this.logs,
    required this.periode,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const _EtatVide();
    }

    // On indexe les logs par jour pour pouvoir parcourir la période complète
    // et placer un point uniquement sur les jours remplis.
    final parDate = <String, JournalQuotidien>{};
    for (final l in logs) {
      parDate[_cleJour(l.date)] = l;
    }

    final aujourdhui = DateTime.now();
    final debut = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day)
        .subtract(Duration(days: periode.jours - 1));

    final spots = <FlSpot>[];
    final couleursPoints = <Color>[];
    for (int i = 0; i < periode.jours; i++) {
      final jour = debut.add(Duration(days: i));
      final log = parDate[_cleJour(jour)];
      if (log != null) {
        spots.add(FlSpot(i.toDouble(), log.scoreQuotidien));
        couleursPoints.add(log.couleurDuJour);
      }
    }

    // Si on a au moins 1 point, on dessine la courbe — sinon on garde
    // une grille vide avec un message.
    if (spots.length < 2) {
      return _EtatPeuDeDonnees(nbPoints: spots.length);
    }

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (periode.jours - 1).toDouble(),
          minY: 0,
          maxY: 10,
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
                interval: _intervalleLabelsX(),
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= periode.jours) {
                    return const SizedBox.shrink();
                  }
                  final jour = debut.add(Duration(days: i));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _labelX(jour),
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
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  const Color(0xFF4C4A73).withOpacity(0.92),
              getTooltipItems: (touched) => touched.map((s) {
                final i = s.x.toInt();
                final jour = debut.add(Duration(days: i));
                return LineTooltipItem(
                  '${DateFormat('d MMM', 'fr_FR').format(jour)}\n${s.y.toStringAsFixed(1)}/10',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.32,
              preventCurveOverShooting: true,
              color: const Color(0xFFB79CED),
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFB79CED).withOpacity(0.28),
                    const Color(0xFFB79CED).withOpacity(0.0),
                  ],
                ),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  // index ici porte sur l'ordre des spots, pas l'index de jour
                  final couleur = index < couleursPoints.length
                      ? couleursPoints[index]
                      : const Color(0xFFB79CED);
                  return FlDotCirclePainter(
                    radius: 5,
                    color: couleur,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Choisit la fréquence des labels sur l'axe X pour éviter le chevauchement.
  double _intervalleLabelsX() {
    switch (periode) {
      case PeriodeStats.semaine:
        return 1;
      case PeriodeStats.mois:
        return 5;
      case PeriodeStats.trimestre:
        return 15;
    }
  }

  String _labelX(DateTime jour) {
    switch (periode) {
      case PeriodeStats.semaine:
        return DateFormat('E', 'fr_FR')
            .format(jour)
            .replaceAll('.', '')
            .substring(0, 1)
            .toUpperCase();
      case PeriodeStats.mois:
        return DateFormat('d/M', 'fr_FR').format(jour);
      case PeriodeStats.trimestre:
        return DateFormat('MMM', 'fr_FR').format(jour);
    }
  }

  static String _cleJour(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _EtatVide extends StatelessWidget {
  const _EtatVide();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 140,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Remplis ton premier questionnaire pour voir tes tendances 🌸',
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
}

class _EtatPeuDeDonnees extends StatelessWidget {
  final int nbPoints;
  const _EtatPeuDeDonnees({required this.nbPoints});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            nbPoints == 0
                ? 'Aucun log sur cette période.'
                : 'Encore un peu de patience : il faut au moins 2 jours remplis pour tracer la courbe.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8B87A3),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}
