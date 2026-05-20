import 'package:flutter/material.dart';

/// Toggle pour indiquer si la journée est un jour de règles.
/// Utilisé dans le questionnaire — séparé pour rester un widget atomique
/// (réutilisable dans les réglages du cycle).
class MenstruationToggle extends StatelessWidget {
  final bool valeur;
  final ValueChanged<bool> onChanged;

  const MenstruationToggle({
    super.key,
    required this.valeur,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          valeur ? Icons.water_drop : Icons.water_drop_outlined,
          color: valeur ? const Color(0xFFE8A0A0) : const Color(0xFF8B87A3),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            valeur ? 'Oui, j\'ai mes règles aujourd\'hui' : 'Non, pas de règles',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4C4A73),
            ),
          ),
        ),
        Switch(
          value: valeur,
          onChanged: onChanged,
          activeColor: const Color(0xFFE8A0A0),
        ),
      ],
    );
  }
}