import 'package:flutter/material.dart';

/// Une entrée d'auto-évaluation pour une journée.
///
/// Toutes les valeurs subjectives (humeur, sommeil, stress, énergie, libido)
/// sont sur une échelle de 1 à 10. La formule de score quotidien :
///
///     score = (humeur × 0.4) + (sommeil × 0.3) − (stress × 0.3)
///
/// Le score est ensuite clamp dans [0..10] et utilisé pour colorer la cellule
/// du calendrier (gris ↔ vif).
class DailyLog {
  final DateTime date;

  /// Échelle 1-10
  final double humeur;
  final double sommeil; // qualité ressentie du sommeil
  final double stress;
  final double energie;
  final double libido;

  /// Heures de sommeil (0-12)
  final double heuresSommeil;

  /// L'utilisatrice a-t-elle ses règles aujourd'hui ?
  final bool estMenstruation;

  /// Activité physique pratiquée (libellé court).
  /// Ex: "Aucun", "Marche", "Yoga", "Cardio", "Musculation"
  final String activite;

  /// Symptômes ressentis (chips multi-sélection).
  /// Ex: ["Crampes", "Maux de tête", "Acné"]
  final List<String> symptomes;

  /// Note libre de l'utilisatrice (optionnelle).
  final String? note;

  const DailyLog({
    required this.date,
    required this.humeur,
    required this.sommeil,
    required this.stress,
    required this.energie,
    required this.libido,
    required this.heuresSommeil,
    required this.estMenstruation,
    required this.activite,
    required this.symptomes,
    this.note,
  });

  /// Score quotidien (0.0 - 10.0) calculé selon la formule du cahier des charges.
  /// Permet de déterminer la "couleur du jour".
  double get scoreQuotidien {
    final score = (humeur * 0.4) + (sommeil * 0.3) - (stress * 0.3);
    // Stress soustrait peut donner un score négatif → on rebascule.
    final ajuste = score + 3.0; // décalage pour rester majoritairement positif
    return ajuste.clamp(0.0, 10.0);
  }

  /// Couleur correspondant au score (du gris au violet vif).
  /// Utilisée par les calendarBuilders dans CalendarPage.
  Color get couleurDuJour {
    final score = scoreQuotidien;
    if (score >= 8.0) return const Color(0xFFB79CED); // sirène vif
    if (score >= 6.5) return const Color(0xFFD3BFF2); // sirène moyen
    if (score >= 5.0) return const Color(0xFFE8DDF5); // sirène pâle
    if (score >= 3.5) return const Color(0xFFEFE8F5); // gris-violet très pâle
    return const Color(0xFFE0E0E0); // gris (mauvaise journée)
  }

  /// Libellé court du score, pour l'afficher dans la fiche du jour.
  String get libelleScore {
    final score = scoreQuotidien;
    if (score >= 8.0) return 'Excellente journée';
    if (score >= 6.5) return 'Bonne journée';
    if (score >= 5.0) return 'Journée correcte';
    if (score >= 3.5) return 'Journée difficile';
    return 'Journée éprouvante';
  }

  /// Sérialisation pour Supabase (Étape 4 du plan).
  /// Pas utilisée pour l'instant mais prête à brancher.
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().substring(0, 10),
        'humeur': humeur,
        'sommeil': sommeil,
        'stress': stress,
        'energie': energie,
        'libido': libido,
        'heures_sommeil': heuresSommeil,
        'est_menstruation': estMenstruation,
        'activite': activite,
        'symptomes': symptomes,
        'note': note,
        'score': scoreQuotidien,
      };

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
        date: DateTime.parse(json['date'] as String),
        humeur: (json['humeur'] as num).toDouble(),
        sommeil: (json['sommeil'] as num).toDouble(),
        stress: (json['stress'] as num).toDouble(),
        energie: (json['energie'] as num).toDouble(),
        libido: (json['libido'] as num).toDouble(),
        heuresSommeil: (json['heures_sommeil'] as num).toDouble(),
        estMenstruation: json['est_menstruation'] as bool,
        activite: json['activite'] as String,
        symptomes: List<String>.from(json['symptomes'] as List),
        note: json['note'] as String?,
      );
}
