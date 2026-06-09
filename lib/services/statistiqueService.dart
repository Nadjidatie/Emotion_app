import 'package:emotion_app/model/cycle_phase.dart';
import 'package:emotion_app/model/humeurOption.dart';
import 'package:emotion_app/model/journalQuotidien.dart';
import 'package:emotion_app/services/cycleService.dart';

enum PeriodeStats {
  semaine,
  mois,
  trimestre,
}

extension PeriodeStatsX on PeriodeStats {
  int get jours {
    switch (this) {
      case PeriodeStats.semaine:
        return 7;
      case PeriodeStats.mois:
        return 30;
      case PeriodeStats.trimestre:
        return 90;
    }
  }

  String get libelle {
    switch (this) {
      case PeriodeStats.semaine:
        return 'Semaine';
      case PeriodeStats.mois:
        return 'Mois';
      case PeriodeStats.trimestre:
        return '3 mois';
    }
  }
}

class TrancheHumeur {
  final String libelle;
  final int compte;
  final double pourcentage;
  final HumeurOption? option;

  const TrancheHumeur({
    required this.libelle,
    required this.compte,
    required this.pourcentage,
    this.option,
  });
}

class StatsParPhase {
  final CyclePhase phase;
  final double scoreMoyen;
  final int nbJours;

  const StatsParPhase({
    required this.phase,
    required this.scoreMoyen,
    required this.nbJours,
  });
}

class Tendance {
  final String texte;
  final String emoji;
  const Tendance(this.emoji, this.texte);
}


class StatistiquesService {

  static List<JournalQuotidien> logsDeLaPeriode(
    List<JournalQuotidien> tous,
    PeriodeStats periode,
  ) {
    final aujourdhui = DateTime.now();
    final debut = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day)
        .subtract(Duration(days: periode.jours - 1));
    return tous.where((l) => !l.date.isBefore(debut)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static double scoreMoyen(List<JournalQuotidien> logs) {
    if (logs.isEmpty) return 0;
    final somme = logs.fold<double>(0, (acc, l) => acc + l.scoreQuotidien);
    return somme / logs.length;
  }

  static double sommeilMoyen(List<JournalQuotidien> logs) {
    if (logs.isEmpty) return 0;
    final somme = logs.fold<double>(0, (acc, l) => acc + l.heuresSommeil);
    return somme / logs.length;
  }

  static int totalSymptomes(List<JournalQuotidien> logs) {
    int total = 0;
    for (final l in logs) {
      for (final s in l.symptomes) {
        if (s != 'Aucun') total++;
      }
    }
    return total;
  }

  static List<TrancheHumeur> repartitionHumeurs(
    List<JournalQuotidien> logs, {
    int maxTranches = 5,
  }) {
    final compte = <String, int>{};
    int totalSelections = 0;
    for (final l in logs) {
      for (final String h in l.humeurs) {
        compte[h] = (compte[h] ?? 0) + 1;
        totalSelections++;
      }
    }
    if (totalSelections == 0) return const [];

    final triees = compte.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final tranches = <TrancheHumeur>[];
    final aGrouper = <MapEntry<String, int>>[];

    for (int i = 0; i < triees.length; i++) {
      if (i < maxTranches - 1) {
        final opt = HumeurCatalogue.parCle(triees[i].key);
        tranches.add(TrancheHumeur(
          libelle: opt?.libelle ?? triees[i].key,
          compte: triees[i].value,
          pourcentage: triees[i].value * 100 / totalSelections,
          option: opt,
        ));
      } else {
        aGrouper.add(triees[i]);
      }
    }

    if (aGrouper.isNotEmpty) {
      final compteAutre = aGrouper.fold<int>(0, (a, e) => a + e.value);
      tranches.add(TrancheHumeur(
        libelle: 'Autre',
        compte: compteAutre,
        pourcentage: compteAutre * 100 / totalSelections,
        option: null,
      ));
    }

    return tranches;
  }

  static List<StatsParPhase> scoreParPhase(
    List<JournalQuotidien> logs,
    CycleService cycle,
  ) {
    final compteurs = <CyclePhase, ({double somme, int nb})>{};
    for (final phase in CyclePhase.values) {
      compteurs[phase] = (somme: 0, nb: 0);
    }
    for (final l in logs) {
      final phase = cycle.phasePour(l.date);
      final c = compteurs[phase]!;
      compteurs[phase] = (somme: c.somme + l.scoreQuotidien, nb: c.nb + 1);
    }
    return CyclePhase.values.map((p) {
      final c = compteurs[p]!;
      return StatsParPhase(
        phase: p,
        scoreMoyen: c.nb == 0 ? 0 : c.somme / c.nb,
        nbJours: c.nb,
      );
    }).toList();
  }

  static List<Tendance> calculerTendances(
    List<JournalQuotidien> logsPeriode,
    List<JournalQuotidien> tousLesLogs,
    CycleService cycle,
  ) {
    final tendances = <Tendance>[];

    if (logsPeriode.isEmpty) return tendances;

    final scoreActuel = scoreMoyen(logsPeriode);
    final premierJourPeriode = logsPeriode.first.date;
    final duree = logsPeriode.length;
    final logsPrecedents = tousLesLogs
        .where((l) =>
            l.date.isBefore(premierJourPeriode) &&
            !l.date.isBefore(
                premierJourPeriode.subtract(Duration(days: duree))))
        .toList();
    if (logsPrecedents.length >= 3) {
      final scorePrecedent = scoreMoyen(logsPrecedents);
      final diff = scoreActuel - scorePrecedent;
      if (diff.abs() >= 0.3) {
        tendances.add(
          Tendance(
            diff > 0 ? '📈' : '📉',
            diff > 0
                ? 'Ton score moyen est en hausse (${scoreActuel.toStringAsFixed(1)} vs ${scorePrecedent.toStringAsFixed(1)}).'
                : 'Ton score moyen est en baisse (${scoreActuel.toStringAsFixed(1)} vs ${scorePrecedent.toStringAsFixed(1)}).',
          ),
        );
      }
    }

    final scoreWeekend = _scoreMoyenSur(
        logsPeriode, (d) => d.weekday == DateTime.saturday || d.weekday == DateTime.sunday);
    final scoreSemaine = _scoreMoyenSur(
        logsPeriode, (d) => d.weekday >= DateTime.monday && d.weekday <= DateTime.friday);
    if (scoreWeekend != null && scoreSemaine != null) {
      final diff = scoreWeekend - scoreSemaine;
      if (diff.abs() >= 0.5) {
        tendances.add(
          Tendance(
            '💆',
            diff > 0
                ? 'Tu te sens plus détendue le week-end.'
                : 'Tu te sens mieux en semaine qu\'en week-end.',
          ),
        );
      }
    }

    final parPhase = scoreParPhase(logsPeriode, cycle);
    final phasesAvecDonnees = parPhase.where((s) => s.nbJours >= 2).toList();
    if (phasesAvecDonnees.length >= 2) {
      phasesAvecDonnees.sort((a, b) => b.scoreMoyen.compareTo(a.scoreMoyen));
      final top = phasesAvecDonnees.first;
      final info = CyclePhaseInfo.of(top.phase);
      tendances.add(
        Tendance(
          '🌸',
          'Tu te sens en moyenne mieux en ${info.nom.toLowerCase()}.',
        ),
      );
    }

    final compteSymptomes = <String, int>{};
    for (final l in logsPeriode) {
      for (final s in l.symptomes) {
        if (s == 'Aucun') continue;
        compteSymptomes[s] = (compteSymptomes[s] ?? 0) + 1;
      }
    }
    if (compteSymptomes.isNotEmpty) {
      final top = compteSymptomes.entries
          .reduce((a, b) => a.value >= b.value ? a : b);
      if (top.value >= 2) {
        tendances.add(
          Tendance(
            '💧',
            'Symptôme le plus fréquent : ${top.key.toLowerCase()} (${top.value} jours).',
          ),
        );
      }
    }

    final repart = repartitionHumeurs(logsPeriode, maxTranches: 5);
    if (repart.isNotEmpty && repart.first.option != null) {
      final top = repart.first;
      tendances.add(
        Tendance(
          '✨',
          'Humeur dominante : ${top.libelle.toLowerCase()} (${top.pourcentage.toStringAsFixed(0)} %).',
        ),
      );
    }

    return tendances.take(4).toList();
  }

  static double? _scoreMoyenSur(
    List<JournalQuotidien> logs,
    bool Function(DateTime) predicat,
  ) {
    final sel = logs.where((l) => predicat(l.date)).toList();
    if (sel.length < 2) return null;
    return scoreMoyen(sel);
  }
}