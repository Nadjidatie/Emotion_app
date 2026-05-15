import 'dart:math';

import '../models/cycle_phase.dart';
import '../models/daily_log.dart';
import 'cycle_service.dart';

/// Génère des logs factices pour les 60 derniers jours.
///
/// Utilisé tant que la table `daily_logs` n'est pas branchée sur Supabase
/// (Étape 4 du cahier des charges). Permet de :
///   - voir tout de suite le calendrier coloré ;
///   - tester l'écran de statistiques ;
///   - démontrer le rendu sans devoir remplir 60 questionnaires à la main.
///
/// Les valeurs sont biaisées par la phase du cycle : on simule par exemple
/// un pic d'humeur en phase ovulatoire et un creux en phase lutéale.
class MockDataService {
  static const _activites = ['Aucun', 'Marche', 'Yoga', 'Cardio', 'Musculation'];

  static const _symptomesParPhase = {
    CyclePhase.menstruelle: ['Crampes', 'Fatigue', 'Maux de tête'],
    CyclePhase.folliculaire: ['Énergique'],
    CyclePhase.ovulatoire: ['Libido haute', 'Énergique'],
    CyclePhase.luteale: ['Ballonnements', 'Acné', 'Sautes d\'humeur'],
  };

  /// Remplit [CycleService] avec 60 jours d'historique simulé.
  static void seed({int joursDhistorique = 60}) {
    final cycle = CycleService.instance;
    final aujourdhui = DateTime.now();
    final random = Random(42); // graine fixe → résultats reproductibles

    final logs = <DailyLog>[];
    for (var i = joursDhistorique; i > 0; i--) {
      final date = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day)
          .subtract(Duration(days: i));
      logs.add(_genererLog(date, cycle.phasePour(date), random));
    }

    cycle.chargerLogs(logs);
  }

  static DailyLog _genererLog(DateTime date, CyclePhase phase, Random random) {
    // Bornes humeur/énergie/stress en fonction de la phase.
    double humeur, sommeil, stress, energie, libido;
    double heuresSommeil;
    bool estMenstruation = false;

    switch (phase) {
      case CyclePhase.menstruelle:
        humeur = 4 + random.nextDouble() * 3; // 4-7
        sommeil = 5 + random.nextDouble() * 3;
        stress = 5 + random.nextDouble() * 3;
        energie = 3 + random.nextDouble() * 3;
        libido = 2 + random.nextDouble() * 3;
        heuresSommeil = 7 + random.nextDouble() * 2;
        estMenstruation = true;
        break;
      case CyclePhase.folliculaire:
        humeur = 6 + random.nextDouble() * 3; // 6-9
        sommeil = 6 + random.nextDouble() * 3;
        stress = 3 + random.nextDouble() * 3;
        energie = 6 + random.nextDouble() * 3;
        libido = 5 + random.nextDouble() * 3;
        heuresSommeil = 7 + random.nextDouble() * 2;
        break;
      case CyclePhase.ovulatoire:
        humeur = 7 + random.nextDouble() * 3; // 7-10
        sommeil = 7 + random.nextDouble() * 2;
        stress = 2 + random.nextDouble() * 3;
        energie = 8 + random.nextDouble() * 2;
        libido = 7 + random.nextDouble() * 3;
        heuresSommeil = 7 + random.nextDouble() * 2;
        break;
      case CyclePhase.luteale:
        humeur = 4 + random.nextDouble() * 4; // plus variable
        sommeil = 4 + random.nextDouble() * 4;
        stress = 5 + random.nextDouble() * 4;
        energie = 4 + random.nextDouble() * 3;
        libido = 3 + random.nextDouble() * 3;
        heuresSommeil = 6 + random.nextDouble() * 3;
        break;
    }

    final activite = _activites[random.nextInt(_activites.length)];

    // Tirer 0 à 2 symptômes typiques de la phase.
    final pool = _symptomesParPhase[phase] ?? const [];
    final nbSymptomes = pool.isEmpty ? 0 : random.nextInt(min(3, pool.length + 1));
    final symptomes = <String>[];
    final melange = [...pool]..shuffle(random);
    for (var i = 0; i < nbSymptomes; i++) {
      symptomes.add(melange[i]);
    }

    return DailyLog(
      date: date,
      humeur: _arrondir(humeur),
      sommeil: _arrondir(sommeil),
      stress: _arrondir(stress),
      energie: _arrondir(energie),
      libido: _arrondir(libido),
      heuresSommeil: double.parse(heuresSommeil.toStringAsFixed(1)),
      estMenstruation: estMenstruation,
      activite: activite,
      symptomes: symptomes,
      note: null,
    );
  }

  static double _arrondir(double v) =>
      double.parse(v.clamp(1.0, 10.0).toStringAsFixed(1));
}
