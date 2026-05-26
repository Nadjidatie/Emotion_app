import 'package:flutter/material.dart';

/// Stepper numérique avec boutons −/+ encadrant une valeur centrée.
///
/// Réutilisable pour les réglages du cycle (longueur, durée), mais aussi
/// potentiellement pour d'autres champs numériques (objectifs sommeil, etc.).
class StepperNumerique extends StatelessWidget {
  final int valeur;
  final int min;
  final int max;
  final int pas;
  final String suffixe; // ex: ' jours'
  final ValueChanged<int> onChanged;

  const StepperNumerique({
    super.key,
    required this.valeur,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.pas = 1,
    this.suffixe = '',
  });

  void _decrementer() {
    final n = (valeur - pas).clamp(min, max);
    if (n != valeur) onChanged(n);
  }

  void _incrementer() {
    final n = (valeur + pas).clamp(min, max);
    if (n != valeur) onChanged(n);
  }

  @override
  Widget build(BuildContext context) {
    final boutonStyle = BoxDecoration(
      color: const Color(0xFFB79CED).withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Bouton(
          icone: Icons.remove,
          actif: valeur > min,
          decoration: boutonStyle,
          onTap: _decrementer,
        ),
        const SizedBox(width: 18),
        Container(
          constraints: const BoxConstraints(minWidth: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8DDF5)),
          ),
          child: Text(
            '$valeur$suffixe',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4C4A73),
            ),
          ),
        ),
        const SizedBox(width: 18),
        _Bouton(
          icone: Icons.add,
          actif: valeur < max,
          decoration: boutonStyle,
          onTap: _incrementer,
        ),
      ],
    );
  }
}

class _Bouton extends StatelessWidget {
  final IconData icone;
  final bool actif;
  final BoxDecoration decoration;
  final VoidCallback onTap;

  const _Bouton({
    required this.icone,
    required this.actif,
    required this.decoration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: actif ? onTap : null,
      child: Opacity(
        opacity: actif ? 1 : 0.35,
        child: Container(
          width: 44,
          height: 44,
          decoration: decoration,
          alignment: Alignment.center,
          child: Icon(icone, color: const Color(0xFFB79CED), size: 22),
        ),
      ),
    );
  }
}
