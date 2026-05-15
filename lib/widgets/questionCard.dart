import 'package:flutter/material.dart';

/// Carte enveloppe pour une question du questionnaire.
///
/// Réutilisable pour TOUS les types de questions (slider, chips, time picker,
/// switch, etc.) — c'est la brique qui satisfait le critère
/// **Réutilisation des widgets** du cahier des charges.
///
/// Pattern : on passe le titre, le sous-titre et l'enfant (le contrôle réel).
class QuestionCard extends StatelessWidget {
  final String titre;
  final String? sousTitre;
  final IconData? icone;
  final Widget child;

  const QuestionCard({
    super.key,
    required this.titre,
    required this.child,
    this.sousTitre,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DDF5), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB79CED).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icone != null) ...[
                Icon(icone, color: const Color(0xFFB79CED), size: 22),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4C4A73),
                  ),
                ),
              ),
            ],
          ),
          if (sousTitre != null) ...[
            const SizedBox(height: 4),
            Text(
              sousTitre!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B87A3),
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
