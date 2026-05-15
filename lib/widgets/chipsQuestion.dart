import 'package:flutter/material.dart';

/// Wrap de chips sélectionnables — multi-sélection ou sélection unique.
///
/// Réutilisé pour :
///  - les symptômes (multi-sélection)
///  - le type d'activité physique (sélection unique)
///  - les humeurs spécifiques (multi-sélection)
class ChipsQuestion extends StatelessWidget {
  final List<String> options;
  final List<String> selection;
  final ValueChanged<List<String>> onChanged;
  final bool multiSelection;

  const ChipsQuestion({
    super.key,
    required this.options,
    required this.selection,
    required this.onChanged,
    this.multiSelection = true,
  });

  void _toggle(String option) {
    final nouvelle = List<String>.from(selection);
    if (multiSelection) {
      if (nouvelle.contains(option)) {
        nouvelle.remove(option);
      } else {
        nouvelle.add(option);
      }
    } else {
      nouvelle
        ..clear()
        ..add(option);
    }
    onChanged(nouvelle);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final actif = selection.contains(opt);
        return GestureDetector(
          onTap: () => _toggle(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: actif ? const Color(0xFFB79CED) : Colors.white,
              border: Border.all(
                color: actif
                    ? const Color(0xFFB79CED)
                    : const Color(0xFFE8DDF5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 14,
                color: actif ? Colors.white : const Color(0xFF4C4A73),
                fontWeight: actif ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
