import 'package:emotion_app/model/cycle_phase.dart';
import 'package:emotion_app/model/journalQuotidien.dart';
import 'package:flutter/foundation.dart';

import '../models/cycle_phase.dart';
import '../models/journalQuotidien.dart';

/// Service central de la logique du cycle.
///
/// Responsabilités :
///  1. Calculer la phase courante à partir du dernier début de règles.
///  2. Stocker les logs quotidiens (en mémoire pour l'instant — Étape 4 du
///     cahier des charges remplacera ce stockage par Supabase).
///  3. Exposer un [ChangeNotifier] pour que l'UI se rafraîchisse quand un
///     nouveau log est sauvegardé.
///
/// Implémenté en singleton pour partager les données entre les écrans
/// (Accueil, Calendrier, Statistiques) sans avoir à introduire un état
/// global plus complexe (Provider/Riverpod) — l'app reste légère.
class CycleService extends ChangeNotifier {
  CycleService._internal();
  static final CycleService instance = CycleService._internal();

  /// Date du début des dernières règles (paramètre utilisateur).
  /// Initialisée à une valeur par défaut pour que la démo fonctionne dès
  /// le premier lancement, sans avoir à passer par les réglages.
  DateTime _dernieresRegles =
      DateTime.now().subtract(const Duration(days: 12));

  /// Longueur moyenne du cycle (par défaut : 28 jours).
  int _longueurCycle = 28;

  /// Durée moyenne des règles (par défaut : 5 jours).
  int _dureeRegles = 5;

  /// Logs indexés par date "YYYY-MM-DD".
  final Map<String, JournalQuotidien> _logs = {};

  // === Getters ===

  DateTime get dernieresRegles => _dernieresRegles;
  int get longueurCycle => _longueurCycle;
  int get dureeRegles => _dureeRegles;

  /// Tous les logs (utile pour les statistiques).
  List<JournalQuotidien> get tousLesLogs =>
      _logs.values.toList()..sort((a, b) => a.date.compareTo(b.date));

  // === Mutations ===

  void definirParametresCycle({
    required DateTime dernieresRegles,
    int? longueurCycle,
    int? dureeRegles,
  }) {
    _dernieresRegles = dernieresRegles;
    if (longueurCycle != null) _longueurCycle = longueurCycle;
    if (dureeRegles != null) _dureeRegles = dureeRegles;
    notifyListeners();
  }

  /// Sauvegarde (ou écrase) un log pour la date donnée.
  void sauvegarderLog(JournalQuotidien log) {
    _logs[_cle(log.date)] = log;
    notifyListeners();
  }

  /// Charge en masse (utilisé par MockDataService et plus tard par Supabase).
  void chargerLogs(Iterable<JournalQuotidien> logs) {
    for (final log in logs) {
      _logs[_cle(log.date)] = log;
    }
    notifyListeners();
  }

  /// Récupère le log d'une date donnée, ou null s'il n'existe pas.
  JournalQuotidien? logPour(DateTime date) => _logs[_cle(date)];

  // === Logique cycle ===

  /// Numéro du jour dans le cycle pour une date donnée (1 = premier jour des règles).
  int jourDuCycle(DateTime date) {
    final diff = _dateOnly(date).difference(_dateOnly(_dernieresRegles)).inDays;
    if (diff < 0) {
      // Avant le début des dernières règles — on rebascule en arrière.
      final reste = diff % _longueurCycle;
      return reste == 0 ? _longueurCycle : _longueurCycle + reste;
    }
    return (diff % _longueurCycle) + 1;
  }

  /// Détermine la phase du cycle pour une date donnée.
  ///
  /// Découpage classique pour un cycle de 28 jours :
  ///  - jours 1-5  : menstruelle
  ///  - jours 6-13 : folliculaire
  ///  - jours 14-16: ovulatoire
  ///  - jours 17-28: lutéale
  ///
  /// Adapté proportionnellement si la longueur du cycle est différente.
  CyclePhase phasePour(DateTime date) {
    final jour = jourDuCycle(date);

    if (jour <= _dureeRegles) return CyclePhase.menstruelle;

    // Ovulation autour du jour (longueurCycle - 14).
    final jourOvulation = _longueurCycle - 14;
    if (jour < jourOvulation) return CyclePhase.folliculaire;
    if (jour <= jourOvulation + 2) return CyclePhase.ovulatoire;
    return CyclePhase.luteale;
  }

  /// Indique si une date donnée tombe pendant les règles
  /// (utilisé par le calendrier pour le marqueur rouge).
  bool estJourDeRegles(DateTime date) =>
      phasePour(date) == CyclePhase.menstruelle;

  /// Date prévue des prochaines règles.
  DateTime prochainesRegles() {
    final aujourdhui = _dateOnly(DateTime.now());
    final jourActuel = jourDuCycle(aujourdhui);
    final joursRestants = _longueurCycle - jourActuel + 1;
    return aujourdhui.add(Duration(days: joursRestants));
  }

  // === Helpers privés ===

  static String _cle(DateTime date) {
    final d = _dateOnly(date);
    final m = d.month.toString().padLeft(2, '0');
    final j = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$j';
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}