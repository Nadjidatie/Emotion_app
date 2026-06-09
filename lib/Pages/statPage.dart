import 'package:emotion_app/services/cycleService.dart';
import 'package:emotion_app/services/statistiqueService.dart';
import 'package:emotion_app/widgets/grapheEvolutionScore.dart';
import 'package:emotion_app/widgets/grapheLienCycle.dart';
import 'package:emotion_app/widgets/grapheRepartitionHumeurs.dart';
import 'package:emotion_app/widgets/insightLigne.dart';
import 'package:emotion_app/widgets/miniStatTuile.dart';
import 'package:emotion_app/widgets/navigationBarBoutton.dart';
import 'package:emotion_app/widgets/selecteurPeriode.dart';
import 'package:emotion_app/widgets/statCard.dart';
import 'package:flutter/material.dart';

class StatPage extends StatefulWidget {
  final String userId;
  const StatPage({super.key, required this.userId});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  PeriodeStats _periode = PeriodeStats.semaine;

  @override
  void initState() {
    super.initState();
    CycleService.instance.addListener(_rafraichir);
  }

  @override
  void dispose() {
    CycleService.instance.removeListener(_rafraichir);
    super.dispose();
  }

  void _rafraichir() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cycle = CycleService.instance;
    final tousLesLogs = cycle.tousLesLogs;
    final logsPeriode =
        StatistiquesService.logsDeLaPeriode(tousLesLogs, _periode);

    final scoreMoyen = StatistiquesService.scoreMoyen(logsPeriode);
    final sommeilMoyen = StatistiquesService.sommeilMoyen(logsPeriode);
    final totalSymptomes =
        StatistiquesService.totalSymptomes(logsPeriode);
    final repartHumeurs =
        StatistiquesService.repartitionHumeurs(logsPeriode);
    final statsPhases =
        StatistiquesService.scoreParPhase(logsPeriode, cycle);
    final tendances = StatistiquesService.calculerTendances(
      logsPeriode,
      tousLesLogs,
      cycle,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF5FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4C4A73)),
        title: const Text(
          'Statistiques de ton humeur',
          style: TextStyle(
            color: Color(0xFF4C4A73),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFB79CED),
          onRefresh: () async => setState(() {}),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            children: [
              SelecteurPeriode(
                selection: _periode,
                onChanged: (p) => setState(() => _periode = p),
              ),
              const SizedBox(height: 16),

              StatCard(
                titre: 'Évolution de ton score',
                sousTitre: 'Chaque point = un jour rempli',
                icone: Icons.show_chart,
                child: GrapheEvolutionScore(
                  logs: logsPeriode,
                  periode: _periode,
                ),
              ),
              const SizedBox(height: 14),

              StatCard(
                titre: 'Répartition des humeurs',
                sousTitre: 'Sur les ${_periode.jours} derniers jours',
                icone: Icons.emoji_emotions,
                couleurIcone: const Color(0xFFF5C97E),
                child: GrapheRepartitionHumeurs(tranches: repartHumeurs),
              ),
              const SizedBox(height: 14),

              StatCard(
                titre: 'Lien avec ton cycle',
                sousTitre: 'Score moyen par phase',
                icone: Icons.spa,
                couleurIcone: const Color(0xFFB7D4A8),
                child: GrapheLienCycle(stats: statsPhases),
              ),
              const SizedBox(height: 14),

              if (tendances.isNotEmpty) ...[
                StatCard(
                  titre: 'Tendances',
                  sousTitre: 'Ce que disent tes données',
                  icone: Icons.auto_awesome,
                  couleurIcone: const Color(0xFFD88FB5),
                  child: Column(
                    children: tendances
                        .map((t) => InsightLigne(
                              emoji: t.emoji,
                              texte: t.texte,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.7,
                  children: [
                    MiniStatTuile(
                      libelle: 'Jours remplis',
                      valeur:
                          '${logsPeriode.length}/${_periode.jours}',
                      icone: Icons.check_circle_outline,
                      couleur: const Color(0xFFB79CED),
                    ),
                    MiniStatTuile(
                      libelle: 'Score moyen',
                      valeur: logsPeriode.isEmpty
                          ? '—'
                          : '${scoreMoyen.toStringAsFixed(1)}/10',
                      icone: Icons.favorite,
                      couleur: const Color(0xFFD88FB5),
                    ),
                    MiniStatTuile(
                      libelle: 'Sommeil moyen',
                      valeur: logsPeriode.isEmpty
                          ? '—'
                          : '${sommeilMoyen.toStringAsFixed(1)} h',
                      icone: Icons.bedtime,
                      couleur: const Color(0xFF8B87A3),
                    ),
                    MiniStatTuile(
                      libelle: 'Symptômes total',
                      valeur: totalSymptomes.toString(),
                      icone: Icons.healing,
                      couleur: const Color(0xFFE8A0A0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Navigationbarboutton(
            userId: widget.userId,
            currentRoute: 'stats',
          ),
        ),
      ),
    );
  }
}
