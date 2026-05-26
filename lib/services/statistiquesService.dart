import 'package:emotion_app/model/cycle_phase.dart';
import 'package:emotion_app/model/humeurOption.dart';
import 'package:emotion_app/model/journalQuotidien.dart';
import 'package:emotion_app/services/cycleService.dart';

/// Période d'analyse pour la page Statistiques.
enum PeriodeStats {
  semaine, // 7 derniers jours
  mois,    // 30 derniers jours
  trimestre, // 90 derniers jours
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

/// Une "tranche" du donut Répartition des humeurs.
class TrancheHumeur {
  final String libelle;
  final int compte;
  final double pourcentage; // 0..100
  final HumeurOption? option; // null si "Autre"

  const TrancheHumeur({
    required this.libelle,
    required this.compte,
    required this.pourcentage,
    this.option,
  });
}

/// Score moyen par phase du cycle.
class StatsParPhase {
  final CyclePhase phase;
  final double scoreMoyen; // 0..10
  final int nbJours;

  const StatsParPhase({
    required this.phase,
    required this.scoreMoyen,
    required this.nbJours,
  });
}

/// Une "tendance" / insight affiché dans le bloc Tendances.
class Tendance {
  final String texte;
  final String emoji;
  const Tendance(this.emoji, this.texte);
}

/// Service purement fonctionnel : prend une liste de logs et renvoie
/// les agrégats nécessaires à la page Statistiques.
///
/// Aucun état interne — toutes les fonctions sont statiques et déterministes.
/// Cela rend les calculs testables et facilement réutilisables ailleurs
/// (ex: pour le contexte envoyé au chatbot à l'étape 5).
class StatistiquesService {
  /// Filtre les logs sur les [periode.jours] derniers jours (date d'aujourd'hui
  /// incluse).
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

  /// Score moyen 0..10 sur la liste passée. 0 si vide.
  static double scoreMoyen(List<JournalQuotidien> logs) {
    if (logs.isEmpty) return 0;
    final somme = logs.fold<double>(0, (acc, l) => acc + l.scoreQuotidien);
    return somme / logs.length;
  }

  /// Moyenne des heures de sommeil. 0 si vide.
  static double sommeilMoyen(List<JournalQuotidien> logs) {
    if (logs.isEmpty) return 0;
    final somme = logs.fold<double>(0, (acc, l) => acc + l.heuresSommeil);
    return somme / logs.length;
  }

  /// Nombre total d'occurrences de symptômes (toutes catégories confondues,
  /// hors "Aucun" qui est une non-saisie).
  static int totalSymptomes(List<JournalQuotidien> logs) {
    int total = 0;
    for (final l in logs) {
      for (final s in l.symptomes) {
        if (s != 'Aucun') total++;
      }
    }
    return total;
  }

  /// Répartition des humeurs sur la période : top [maxTranches]-1 + "Autre".
  static List<TrancheHumeur> repartitionHumeurs(
    List<JournalQuotidien> logs, {
    int maxTranches = 5,
  }) {
    final compte = <String, int>{};
    int totalSelections = 0;
    for (final l in logs) {
      for (final h in l.humeurs) {
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

  /// Score moyen par phase du cycle, sur les logs passés en entrée.
  /// On utilise [cycle] pour déterminer la phase de chaque journée.
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

  /// Génère 2 à 4 tendances pertinentes en fonction des données.
  ///
  /// Règles déclenchées seulement si on a assez de logs pour que la
  /// comparaison ait du sens — on évite de raconter n'importe quoi.
  static List<Tendance> calculerTendances(
    List<JournalQuotidien> logsPeriode,
    List<JournalQuotidien> tousLesLogs,
    CycleService cycle,
  ) {
    final tendances = <Tendance>[];

    if (logsPeriode.isEmpty) return tendances;

    // 1) Score moyen et comparaison avec la période précédente (même durée).
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

    // 2) Week-end vs semaine — besoin de jours dans les deux groupes.
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

    // 3) Lien cycle — quelle phase a le meilleur score (≥ 2 jours par phase).
    final parPhase = scoreParPhase(logsPeriode, cycle);
    final phasesAvecDonnees =
        parPhase.where((s) => s.nbJours >= 2).toList();
    if (phasesAvecDonnees.length >= 2) {
      phasesAvecDonnees
          .sort((a, b) => b.scoreMoyen.compareTo(a.scoreMoyen));
      final top = phasesAvecDonnees.first;
      final info = CyclePhaseInfo.of(top.phase);
      tendances.add(
        Tendance(
          '🌸',
          'Tu te sens en moyenne mieux en ${info.nom.toLowerCase()}.',
        ),
      );
    }

    // 4) Symptôme le plus fréquent (hors "Aucun").
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

    // 5) Humeur dominante.
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

    // On limite à 4 tendances max pour ne pas surcharger l'UI.
    return tendances.take(4).toList();
  }

  /// Helper : score moyen sur le sous-ensemble des logs dont la date
  /// vérifie [predicat]. Renvoie null s'il n'y a pas assez de données.
  static double? _scoreMoyenSur(
    List<JournalQuotidien> logs,
    bool Function(DateTime) predicat,
  ) {
    final sel = logs.where((l) => predicat(l.date)).toList();
    if (sel.length < 2) return null;
    return scoreMoyen(sel);
  }
}
