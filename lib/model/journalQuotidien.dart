import 'package:flutter/material.dart';
import 'package:emotion_app/model/humeurOption.dart';

/// scoreBrut = (humeurMoyenne × 0.4) + (sommeil × 0.3) − (stress × 0.3)
/// scoreFinal = normalisation du score brut sur une échelle 0-10

class JournalQuotidien {
  final DateTime date;

  /// Clés des humeurs sélectionnées. Ex: ["heureuse", "anxieuse"]
  final List<String> humeurs;

  /// Qualité du sommeil 1-10
  final double sommeil;
  final double stress;
  final double energie;
  final double libido;

  /// Heures de sommeil (0-12)
  final double heuresSommeil;

  /// L'utilisatrice a-t-elle ses règles aujourd'hui ?
  final bool estMenstruation;

  /// Activité physique pratiquée (libellé court).
  final String activite;

  /// Ex: ["Crampes", "Maux de tête", "Acné"]
  final List<String> symptomes;

  final String? note;

  const JournalQuotidien({
    required this.date,
    required this.humeurs,
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

  double get scoreQuotidien {
    // On délègue le calcul de la valeur numérique au catalogue.
    final humeurVal = HumeurCatalogue.valeurMoyenne(humeurs);
    final scoreBrut = (humeurVal * 0.4) + (sommeil * 0.3) - (stress * 0.3);

    // Bornes théoriques du score brut avec les curseurs actuels :
    // humeur 2..9, sommeil 1..10, stress 1..10.
    const minBrut = -1.9;
    const maxBrut = 6.3;
    final scoreNormalise = ((scoreBrut - minBrut) / (maxBrut - minBrut)) * 10;

    return scoreNormalise.clamp(0.0, 10.0);
  }

  Color get couleurDuJour {
    final score = scoreQuotidien;
    if (score >= 8.0) return const Color(0xFFB79CED);
    if (score >= 6.5) return const Color(0xFFD3BFF2);
    if (score >= 5.0) return const Color(0xFFE8DDF5);
    if (score >= 3.5) return const Color(0xFFEFE8F5);
    return const Color(0xFFE0E0E0);
  }

  String get libelleScore {
    final score = scoreQuotidien;
    if (score >= 8.0) return 'Excellente journée';
    if (score >= 6.5) return 'Bonne journée';
    if (score >= 5.0) return 'Journée correcte';
    if (score >= 3.5) return 'Journée difficile';
    return 'Journée éprouvante';
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().substring(0, 10),
        'humeurs': humeurs,
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

  factory JournalQuotidien.fromJson(Map<String, dynamic> json) =>
      JournalQuotidien(
        date: DateTime.parse(json['date'] as String),
        humeurs: json['humeurs'] != null
            ? List<String>.from(json['humeurs'] as List)
            : [],
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
