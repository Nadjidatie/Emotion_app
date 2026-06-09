import 'package:emotion_app/model/cycle_phase.dart';
import 'package:emotion_app/model/journalQuotidien.dart';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CycleService extends ChangeNotifier {
  CycleService._internal();
  static final CycleService instance = CycleService._internal();

  final _supabase = Supabase.instance.client;

  DateTime _dernieresRegles = DateTime.now().subtract(const Duration(days: 12));
  // valeur de base chargée depuis Supabase, pour pouvoir restaurer si on démarque
  DateTime _dernieresReglesBase = DateTime.now().subtract(const Duration(days: 12));
  int _longueurCycle = 28;
  int _dureeRegles = 5;
  final Map<String, JournalQuotidien> _logs = {};

  // jours marqués manuellement par l'utilisatrice (format 'YYYY-MM-DD')
  final Set<String> _joursReglesMarques = {};

  DateTime get dernieresRegles => _dernieresRegles;
  int get longueurCycle => _longueurCycle;
  int get dureeRegles => _dureeRegles;

  List<JournalQuotidien> get tousLesLogs =>
      _logs.values.toList()..sort((a, b) => a.date.compareTo(b.date));

  bool estJourReglesMarque(DateTime date) =>
      _joursReglesMarques.contains(_cle(date));

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
          .select('dernieres-regles, longueur-cycle, duree-regles')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return;

      if (data['dernieres-regles'] != null) {
        _dernieresRegles =
            DateTime.tryParse(data['dernieres-regles']) ?? _dernieresRegles;
        _dernieresReglesBase = _dernieresRegles;
      }
      if (data['longueur-cycle'] != null) {
        _longueurCycle = data['longueur-cycle'] as int;
      }
      if (data['duree-regles'] != null) {
        _dureeRegles = data['duree-regles'] as int;
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
        'dernieres-regles': dernieresRegles.toIso8601String().substring(0, 10),
        'longueur-cycle': _longueurCycle,
        'duree-regles': _dureeRegles,
      }).eq('id', userId);
    } catch (e) {
      print('ERREUR sauvegarde paramètres cycle: $e');
    }
  }

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

  void chargerLogs(Iterable<JournalQuotidien> logs) {
    for (final log in logs) {
      _logs[_cle(log.date)] = log;
    }
    notifyListeners();
  }

  JournalQuotidien? logPour(DateTime date) => _logs[_cle(date)];

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

  bool estJourDeRegles(DateTime date) =>
      estJourReglesMarque(date) ||
      phasePour(date) == CyclePhase.menstruelle;

  Future<void> marquerJourRegles(DateTime date, bool marque) async {
    final cle = _cle(date);
    if (marque) {
      _joursReglesMarques.add(cle);
      _recalibrerDernieresRegles(date);
    } else {
      _joursReglesMarques.remove(cle);
      _restaurerOuRecalibrer();
    }
    notifyListeners();
    await _sauvegarderDernieresRegles();
  }

  Future<void> _sauvegarderDernieresRegles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _supabase.from('profiles').update({
        'dernieres-regles': _dernieresRegles.toIso8601String().substring(0, 10),
      }).eq('id', userId);
    } catch (e) {
      print('ERREUR sauvegarde dernieres-regles: $e');
    }
  }

  void _restaurerOuRecalibrer() {
    if (_joursReglesMarques.isEmpty) {
      _dernieresRegles = _dernieresReglesBase;
      return;
    }
    final dates = _joursReglesMarques
        .map((s) => DateTime.parse(s))
        .toList()
      ..sort((a, b) => b.compareTo(a));
    _recalibrerDernieresRegles(dates.first);
  }

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

  static String _cle(DateTime date) {
    final d = _dateOnly(date);
    final m = d.month.toString().padLeft(2, '0');
    final j = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$j';
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
