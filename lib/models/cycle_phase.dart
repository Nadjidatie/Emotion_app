import 'package:flutter/material.dart';

/// Les 4 phases du cycle menstruel.
///
/// Utilisé partout dans l'app pour :
///  - colorer la phase courante sur l'écran d'accueil ;
///  - afficher des conseils contextuels (sport, alimentation, sommeil) ;
///  - donner du contexte au chatbot ("L'utilisatrice est en phase lutéale...").
enum CyclePhase {
  menstruelle,
  folliculaire,
  ovulatoire,
  luteale,
}

/// Informations descriptives associées à une phase du cycle.
///
/// Centralisées ici pour pouvoir être réutilisées dans :
///  - [CurrentPhaseCard] (écran d'accueil)
///  - [CalendarPage] (légende et détail du jour)
///  - le prompt envoyé au chatbot
class CyclePhaseInfo {
  final CyclePhase phase;
  final String nom;
  final String description;
  final String hormones;
  final String conseil;
  final Color couleur;
  final IconData icone;

  const CyclePhaseInfo({
    required this.phase,
    required this.nom,
    required this.description,
    required this.hormones,
    required this.conseil,
    required this.couleur,
    required this.icone,
  });

  /// Récupère les informations détaillées d'une phase donnée.
  static CyclePhaseInfo of(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruelle:
        return const CyclePhaseInfo(
          phase: CyclePhase.menstruelle,
          nom: 'Phase menstruelle',
          description:
              'Ton corps évacue la muqueuse utérine. Énergie basse, besoin de repos et de douceur.',
          hormones:
              'Œstrogènes et progestérone au plus bas. Les prostaglandines peuvent provoquer des crampes.',
          conseil:
              'Privilégie le repos, des aliments riches en fer (lentilles, épinards) et des étirements doux.',
          couleur: Color(0xFFE8A0A0), // rose terracotta doux
          icone: Icons.water_drop,
        );
      case CyclePhase.folliculaire:
        return const CyclePhaseInfo(
          phase: CyclePhase.folliculaire,
          nom: 'Phase folliculaire',
          description:
              'L\'énergie remonte, l\'humeur s\'améliore. C\'est le moment idéal pour démarrer de nouveaux projets.',
          hormones:
              'Les œstrogènes augmentent progressivement, stimulant la motivation et la concentration.',
          conseil:
              'Profite de ton énergie : sport intense, créativité, nouveaux défis. Mise sur les protéines.',
          couleur: Color(0xFFB7D4A8), // vert tendre
          icone: Icons.eco,
        );
      case CyclePhase.ovulatoire:
        return const CyclePhaseInfo(
          phase: CyclePhase.ovulatoire,
          nom: 'Phase ovulatoire',
          description:
              'Tu es au pic de ton énergie et de ta confiance. Sociable, séduisante, performante.',
          hormones:
              'Pic d\'œstrogènes et de LH. La testostérone monte aussi : libido élevée.',
          conseil:
              'C\'est le moment des présentations, rendez-vous importants et entraînements intenses.',
          couleur: Color(0xFFF5C97E), // jaune doré
          icone: Icons.wb_sunny,
        );
      case CyclePhase.luteale:
        return const CyclePhaseInfo(
          phase: CyclePhase.luteale,
          nom: 'Phase lutéale',
          description:
              'Ton corps se prépare à la prochaine menstruation. L\'énergie baisse, l\'introspection grandit.',
          hormones:
              'La progestérone domine, puis chute en fin de phase (SPM possible : irritabilité, ballonnements).',
          conseil:
              'Ralentis le rythme. Yoga, marche, magnésium, chocolat noir et sommeil de qualité.',
          couleur: Color(0xFFB79CED), // sirène (couleur d'accent de l'app)
          icone: Icons.nightlight_round,
        );
    }
  }

  /// Toutes les phases (utile pour la légende).
  static List<CyclePhaseInfo> all() =>
      CyclePhase.values.map((p) => CyclePhaseInfo.of(p)).toList();
}
