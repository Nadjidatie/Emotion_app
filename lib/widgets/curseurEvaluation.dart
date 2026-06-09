import 'package:flutter/material.dart';

/// Slider 1-10 réutilisable pour les questions du questionnaire.
//
/// Utilisé pour : humeur, sommeil (qualité), stress, énergie, libido,
/// heures de sommeil. Une seule définition → six usages.
class SliderQuestion extends StatelessWidget {
  final double valeur;
  final double min;
  final double max;
  final int? divisions;
  final String labelMin;
  final String labelMax;
  final String? Function(double)? formatValeur;
  final ValueChanged<double> onChanged;
  final Color? couleur;

  const SliderQuestion({
    super.key,
    required this.valeur,
    required this.onChanged,
    this.min = 1,
    this.max = 10,
    this.divisions = 9,
    this.labelMin = 'Faible',
    this.labelMax = 'Élevé',
    this.formatValeur,
    this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    final c = couleur ?? const Color(0xFFB79CED);
    final affichage =
        formatValeur != null ? formatValeur!(valeur) : valeur.toStringAsFixed(1);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: c.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            affichage ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: c,
            ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: c,
            inactiveTrackColor: c.withOpacity(0.2),
            thumbColor: c,
            overlayColor: c.withOpacity(0.2),
            trackHeight: 5,
          ),
          child: Slider(
            value: valeur,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(labelMin,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8B87A3))),
            Text(labelMax,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8B87A3))),
          ],
        ),
      ],
    );
  }
}