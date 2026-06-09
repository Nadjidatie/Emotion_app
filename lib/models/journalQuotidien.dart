import 'package:flutter/material.dart';
import 'package:emotion_app/model/humeurOption.dart';


///     scoreBrut = (humeur × 0.4) + (sommeil × 0.3) − (stress × 0.3)
///     scoreFinal = normalisation du score brut sur une échelle 0-10


class JournalQuotidien {
  final DateTime date;

  /// Liste des humeurs sélectionnées (clés du [HumeurCatalogue]).
  /// Ex: ['heureuse', 'energique'] ou ['stressee', 'fatiguee'].
  /// Remplace l'ancien champ numérique `humeur`.
  final List<String> humeurs;

  /// Échelle 1-10
  final double sommeil;
  final double stress;
  final double energie;

  /// Heures de sommeil (0-12)
  final double heuresSommeil;

  /// L'utilisatrice a-t-elle ses règles aujourd'hui ?
  final bool estMenstruation;

  /// Activité physique pratiquée (libellé court).
  /// Ex: "Aucun", "Marche", "Yoga", "Cardio", "Musculation"
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
    required this.heuresSommeil,
    required this.estMenstruation,
    required this.activite,
    required this.symptomes,
    this.note,
  });

  /// Valeur numérique dérivée (moyenne pondérée des humeurs sélectionnées).
  /// Utilisée par la formule du score quotidien.
  double get humeur => HumeurCatalogue.valeurMoyenne(humeurs);

  double get scoreQuotidien {
    final scoreBrut = (humeur * 0.4) + (sommeil * 0.3) - (stress * 0.3);

    // Bornes théoriques du score brut avec les curseurs actuels :
    // humeur 2..9, sommeil 1..10, stress 1..10.
    const minBrut = -1.9;
    const maxBrut = 6.3;
    final scoreNormalise = ((scoreBrut - minBrut) / (maxBrut - minBrut)) * 10;

    return scoreNormalise.clamp(0.0, 10.0);
  }

  Color get couleurDuJour {
    final score = scoreQuotidien;
    if (score >= 8.0) return const Color(0xFFB79CED); // sirène vif
    if (score >= 6.5) return const Color(0xFFD3BFF2); // sirène moyen
    if (score >= 5.0) return const Color(0xFFE8DDF5); // sirène pâle
    if (score >= 3.5) return const Color(0xFFEFE8F5); // gris-violet très pâle
    return const Color(0xFFE0E0E0); // gris (mauvaise journée)
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
        // On garde aussi la valeur numérique dérivée pour la rétro-compat
        // (anciennes lignes Supabase, requêtes analytiques, etc.).
        'humeur': humeur,
        'sommeil': sommeil,
        'stress': stress,
        'energie': energie,
        'heures_sommeil': heuresSommeil,
        'est_menstruation': estMenstruation,
        'activite': activite,
        'symptomes': symptomes,
        'note': note,
        'score': scoreQuotidien,
      };

  factory JournalQuotidien.fromJson(Map<String, dynamic> json) => JournalQuotidien(
        date: DateTime.parse(json['date'] as String),
        // Support des anciennes lignes (sans `humeurs`) : on retombe sur une
        // liste vide → la moyenne renverra 5.0 (humeur neutre).
        humeurs: json['humeurs'] == null
            ? <String>[]
            : List<String>.from(json['humeurs'] as List),
        sommeil: (json['sommeil'] as num).toDouble(),
        stress: (json['stress'] as num).toDouble(),
        energie: (json['energie'] as num).toDouble(),
        heuresSommeil: (json['heures_sommeil'] as num).toDouble(),
        estMenstruation: json['est_menstruation'] as bool,
        activite: json['activite'] as String,
        symptomes: List<String>.from(json['symptomes'] as List),
        note: json['note'] as String?,
      );
}
