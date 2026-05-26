import 'package:emotion_app/services/statistiquesService.dart';
import 'package:flutter/material.dart';

/// Toggle horizontal "pill" pour choisir la période sur la page Statistiques.
///
/// Visuellement aligné sur le segmented control de la maquette : un fond
/// blanc arrondi, l'option active en violet plein.
class SelecteurPeriode extends StatelessWidget {
  final PeriodeStats selection;
  final ValueChanged<PeriodeStats> onChanged;

  const SelecteurPeriode({
    super.key,
    required this.selection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8DDF5)),
      ),
      child: Row(
        children: PeriodeStats.values.map((p) {
          final actif = p == selection;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: actif
                      ? const Color(0xFFB79CED)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  p.libelle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        actif ? Colors.white : const Color(0xFF8B87A3),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
