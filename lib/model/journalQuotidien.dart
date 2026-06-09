import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:emotion_app/model/humeurOption.dart';

class JournalQuotidien {
  final DateTime date;
  final List<String> humeurs;
  final double sommeil;
  final double stress;
  final double energie;
  final double libido;
  final double heuresSommeil;
  final bool estMenstruation;
  final String activite;
  final List<String> symptomes;

  final String? note;

  JournalQuotidien({
    required this.date,
    required this.humeurs,
    required this.sommeil,
    required this.stress,
    required this.energie,
    this.libido = 5.0,
    required this.heuresSommeil,
    required this.estMenstruation,
    required this.activite,
    required this.symptomes,
    this.note,
  });

  double get scoreQuotidien {
    final humeurVal = HumeurCatalogue.valeurMoyenne(humeurs);
    final scoreBrut = (humeurVal * 0.4) + (sommeil * 0.3) - (stress * 0.3);

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
        'humeur': HumeurCatalogue.valeurMoyenne(humeurs),
        'sommeil': sommeil,
        'stress': stress,
        'energie': energie,
        'heures_sommeil': heuresSommeil,
        'est_menstruation': estMenstruation,
        'activite': activite,
        'symptomes': jsonEncode(symptomes),
        'note': note,
        'score': scoreQuotidien,
      };

  factory JournalQuotidien.fromJson(Map<String, dynamic> json) =>
      JournalQuotidien(
        date: DateTime.parse(json['date'] as String),
        humeurs: const [],
        sommeil: (json['sommeil'] as num).toDouble(),
        stress: (json['stress'] as num).toDouble(),
        energie: (json['energie'] as num).toDouble(),
        libido: 5.0,
        heuresSommeil: (json['heures_sommeil'] as num).toDouble(),
        estMenstruation: json['est_menstruation'] as bool,
        activite: json['activite'] as String,
        symptomes: json['symptomes'] == null || json['symptomes'] == '{}'
            ? <String>[]
            : json['symptomes'] is String
                ? List<String>.from(jsonDecode(json['symptomes'] as String) as List)
                : List<String>.from(json['symptomes'] as List),
        note: json['note'] as String?,
      );
}
