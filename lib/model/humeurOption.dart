import 'package:flutter/material.dart';

class HumeurOption {
  final String cle;
  final String libelle;
  final IconData icone;
  final Color couleur;
  final double valeur;

  const HumeurOption({
    required this.cle,
    required this.libelle,
    required this.icone,
    required this.couleur,
    required this.valeur,
  });
}


class HumeurCatalogue {
  // Humeurs positives (valeurs hautes)
  static const heureuse = HumeurOption(
    cle: 'heureuse',
    libelle: 'Heureuse',
    icone: Icons.sentiment_very_satisfied,
    couleur: Color(0xFFF5C97E),
    valeur: 9,
  );
  static const calme = HumeurOption(
    cle: 'calme',
    libelle: 'Calme',
    icone: Icons.spa,
    couleur: Color(0xFFB7D4A8),
    valeur: 8,
  );
  static const energique = HumeurOption(
    cle: 'energique',
    libelle: 'Énergique',
    icone: Icons.bolt,
    couleur: Color(0xFFF7B26B),
    valeur: 8,
  );
  static const contente = HumeurOption(
    cle: 'contente',
    libelle: 'Contente',
    icone: Icons.sentiment_satisfied,
    couleur: Color(0xFFD3BFF2),
    valeur: 7,
  );
  static const amoureuse = HumeurOption(
    cle: 'amoureuse',
    libelle: 'Amoureuse',
    icone: Icons.favorite,
    couleur: Color(0xFFD88FB5),
    valeur: 8,
  );

  static const fatiguee = HumeurOption(
    cle: 'fatiguee',
    libelle: 'Fatiguée',
    icone: Icons.bedtime,
    couleur: Color(0xFF8B87A3),
    valeur: 3,
  );
  static const stressee = HumeurOption(
    cle: 'stressee',
    libelle: 'Stressée',
    icone: Icons.flash_on,
    couleur: Color(0xFFE8A0A0),
    valeur: 2,
  );
  static const triste = HumeurOption(
    cle: 'triste',
    libelle: 'Triste',
    icone: Icons.sentiment_dissatisfied,
    couleur: Color(0xFF9DB5D8),
    valeur: 2,
  );
  static const anxieuse = HumeurOption(
    cle: 'anxieuse',
    libelle: 'Anxieuse',
    icone: Icons.psychology_alt,
    couleur: Color(0xFFC9A9E0),
    valeur: 3,
  );
  static const irritable = HumeurOption(
    cle: 'irritable',
    libelle: 'Irritable',
    icone: Icons.sentiment_very_dissatisfied,
    couleur: Color(0xFFE0A2A2),
    valeur: 3,
  );

  static const List<HumeurOption> toutes = [
    heureuse,
    calme,
    energique,
    contente,
    amoureuse,
    fatiguee,
    stressee,
    triste,
    anxieuse,
    irritable,
  ];

  static HumeurOption? parCle(String cle) {
    for (final h in toutes) {
      if (h.cle == cle) return h;
    }
    return null;
  }

  // retourne la moyenne des valeurs des humeurs sélectionnées (5.0 si vide)
  static double valeurMoyenne(List<String> cles) {
    if (cles.isEmpty) return 5.0;
    double total = 0;
    int n = 0;
    for (final cle in cles) {
      final h = parCle(cle);
      if (h != null) {
        total += h.valeur;
        n++;
      }
    }
    if (n == 0) return 5.0;
    return total / n;
  }
}