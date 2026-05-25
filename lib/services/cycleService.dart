import 'package:emotion_app/model/cycle_phase.dart';
import 'package:emotion_app/model/journalQuotidien.dart';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CycleService extends ChangeNotifier {
  CycleService._internal();
  static final CycleService instance = CycleService._internal();

  final _supabase = Supabase.instance.client;

  DateTime _dernieresRegles = DateTime.now().subtract(const Duration(days: 12));
  int _longueurCycle = 28;
  int _dureeRegles = 5;
  final Map<String, JournalQuotidien> _logs = {};

  /// Jours explicitement marqués comme "règles" par l'utilisatrice via la
  /// barre rapide de l'accueil (style Flo).
  /// Les clés sont au format 'YYYY-MM-DD' (voir [_cle]).
  ///
  /// Source de vérité prioritaire : si une date est dans ce set, elle est
  /// considérée comme jour de règles, indépendamment du calcul de phase.
  final Set<String> _joursReglesMarques = {};

  // === Getters ===

  DateTime get dernieresRegles => _dernieresRegles;
  int get longueurCycle => _longueurCycle;
  int get dureeRegles => _dureeRegles;

  List<JournalQuotidien> get tousLesLogs =>
      _logs.values.toList()..sort((a, b) => a.date.compareTo(b.date));

  /// Est-ce que [date] a été marquée à la main comme jour de règles ?
  bool estJourReglesMarque(DateTime date) =>
      _joursReglesMarques.contains(_cle(date));

  // === Initialisation depuis Supabase ========================================

  /// À appeler au démarrage (ex: dans AuthGate ou Accueil).
  /// Charge les paramètres du cycle ET tous les logs depuis Supabase.
  Future<void> initialiserDepuisSupabase() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await Future.wait([
      _chargerParametres(userId),
      _chargerLogsDepuisSupabase(userId),
    ]);

    notifyListeners();
  }

  Future<void> _chargerParametres(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('dernieres_regles, longueur_cycle, duree_regles')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return;

      if (data['dernieres_regles'] != null) {
        _dernieresRegles =
            DateTime.tryParse(data['dernieres_regles']) ?? _dernieresRegles;
      }
      if (data['longueur_cycle'] != null) {
        _longueurCycle = data['longueur_cycle'] as int;
      }
      if (data['duree_regles'] != null) {
        _dureeRegles = data['duree_regles'] as int;
      }
    } catch (e) {
      print('ERREUR _chargerParametres: $e');
    }
  }

  Future<void> _chargerLogsDepuisSupabase(String userId) async {
    try {
      final rows = await _supabase
          .from('journal_quotidien')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: true);

      _logs.clear();
      for (final row in rows) {
        final log = JournalQuotidien.fromJson(row as Map<String, dynamic>);
        _logs[_cle(log.date)] = log;
      }
    } catch (e) {
      print('ERREUR _chargerLogsDepuisSupabase: $e');
    }
  }

  // === Paramètres du cycle ===================================================

  /// Met à jour les paramètres localement ET dans Supabase (table profiles).
  Future<void> definirParametresCycle({
    required DateTime dernieresRegles,
    int? longueurCycle,
    int? dureeRegles,
  }) async {
    _dernieresRegles = dernieresRegles;
    if (longueurCycle != null) _longueurCycle = longueurCycle;
    if (dureeRegles != null) _dureeRegles = dureeRegles;
    notifyListeners();

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('profiles').update({
        'dernieres_regles': dernieresRegles.toIso8601String().substring(0, 10),
        'longueur_cycle': _longueurCycle,
        'duree_regles': _dureeRegles,
      }).eq('id', userId);
    } catch (e) {
      print('ERREUR sauvegarde paramètres cycle: $e');
    }
  }

  // === Logs quotidiens =======================================================

  /// Sauvegarde un log localement ET dans Supabase.
  Future<void> sauvegarderLog(JournalQuotidien log) async {
    _logs[_cle(log.date)] = log;
    notifyListeners();

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final json = log.toJson();
      json['user_id'] = userId;

      await _supabase.from('journal_quotidien').upsert(
        json,
        onConflict: 'user_id,date',
      );
    } catch (e) {
      print('ERREUR sauvegarderLog: $e');
    }
  }

  /// Charge en masse depuis une liste (MockData ou migration).
  void chargerLogs(Iterable<JournalQuotidien> logs) {
    for (final log in logs) {
      _logs[_cle(log.date)] = log;
    }
    notifyListeners();
  }

  /// Récupère le log d'une date donnée, ou null s'il n'existe pas.
  JournalQuotidien? logPour(DateTime date) => _logs[_cle(date)];

  // === Logique cycle =========================================================

  int jourDuCycle(DateTime date) {
    final diff = _dateOnly(date).difference(_dateOnly(_dernieresRegles)).inDays;
    if (diff < 0) {
      final reste = diff % _longueurCycle;
      return reste == 0 ? _longueurCycle : _longueurCycle + reste;
    }
    return (diff % _longueurCycle) + 1;
  }

  CyclePhase phasePour(DateTime date) {
    final jour = jourDuCycle(date);
    if (jour <= _dureeRegles) return CyclePhase.menstruelle;
    final jourOvulation = _longueurCycle - 14;
    if (jour < jourOvulation) return CyclePhase.folliculaire;
    if (jour <= jourOvulation + 2) return CyclePhase.ovulatoire;
    return CyclePhase.luteale;
  }

  /// Vrai si [date] est un jour de règles, soit parce qu'il a été marqué à
  /// la main, soit parce qu'il tombe dans la phase menstruelle calculée.
  bool estJourDeRegles(DateTime date) =>
      estJourReglesMarque(date) ||
      phasePour(date) == CyclePhase.menstruelle;

  /// Marque (ou démarque) [date] comme jour de règles.
  ///
  /// Quand on marque un jour, on essaie aussi de recaler le début du
  /// dernier cycle ([_dernieresRegles]) sur le premier jour contigu marqué,
  /// pour que la prédiction des phases suive ce que l'utilisatrice a saisi.
  Future<void> marquerJourRegles(DateTime date, bool marque) async {
    final cle = _cle(date);
    if (marque) {
      _joursReglesMarques.add(cle);
      _recalibrerDernieresRegles(date);
    } else {
      _joursReglesMarques.remove(cle);
    }
    notifyListeners();
    // TODO (étape 4) : persister _joursReglesMarques dans Supabase.
  }

  /// Cherche le premier jour contigu marqué dans la fenêtre proche de [date]
  /// (jusqu'à 10 jours en arrière) et place [_dernieresRegles] dessus si
  /// c'est plus pertinent que la valeur actuelle.
  void _recalibrerDernieresRegles(DateTime date) {
    DateTime premierJourBloc = _dateOnly(date);
    for (int i = 1; i <= 10; i++) {
      final candidat = premierJourBloc.subtract(const Duration(days: 1));
      if (_joursReglesMarques.contains(_cle(candidat))) {
        premierJourBloc = candidat;
      } else {
        break;
      }
    }
    // On ne déplace _dernieresRegles que si le bloc nouvellement saisi est
    // plus récent que la dernière valeur connue (évite de remonter dans le
    // temps à cause d'une saisie sur un ancien mois).
    final actuel = _dateOnly(_dernieresRegles);
    if (premierJourBloc.isAfter(actuel) ||
        premierJourBloc.difference(actuel).inDays.abs() <= 3) {
      _dernieresRegles = premierJourBloc;
    }
  }

  DateTime prochainesRegles() {
    final aujourdhui = _dateOnly(DateTime.now());
    final jourActuel = jourDuCycle(aujourdhui);
    final joursRestants = _longueurCycle - jourActuel + 1;
    return aujourdhui.add(Duration(days: joursRestants));
  }

  // === Helpers privés ========================================================

  static String _cle(DateTime date) {
    final d = _dateOnly(date);
    final m = d.month.toString().padLeft(2, '0');
    final j = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$j';
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
