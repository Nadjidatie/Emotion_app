import 'package:flutter/material.dart';
import 'package:emotion_app/model/humeurOption.dart';

/// Grille d'icônes d'humeurs sélectionnables (multi-sélection).
///
/// Remplace l'ancien slider d'intensité de l'humeur : au lieu d'une note
/// 1-10, l'utilisatrice choisit une ou plusieurs humeurs représentées par
/// une icône colorée (Heureuse, Calme, Stressée, Triste, …).
///
/// La valeur numérique utilisée par le `scoreQuotidien` est recalculée
/// automatiquement côté modèle [JournalQuotidien.humeur] à partir des
/// poids définis dans [HumeurCatalogue].
class SelecteurHumeurs extends StatelessWidget {
  final List<String> selection;
  final ValueChanged<List<String>> onChanged;

  const SelecteurHumeurs({
    super.key,
    required this.selection,
    required this.onChanged,
  });

  void _toggle(String cle) {
    final nouvelle = List<String>.from(selection);
    if (nouvelle.contains(cle)) {
      nouvelle.remove(cle);
    } else {
      nouvelle.add(cle);
    }
    onChanged(nouvelle);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: HumeurCatalogue.toutes.map((h) {
        final actif = selection.contains(h.cle);
        return GestureDetector(
          onTap: () => _toggle(h.cle),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 86,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: actif ? h.couleur.withOpacity(0.22) : Colors.white,
              border: Border.all(
                color: actif ? h.couleur : const Color(0xFFE8DDF5),
                width: actif ? 2 : 1.5,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(h.icone, color: h.couleur, size: 28),
                const SizedBox(height: 6),
                Text(
                  h.libelle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF4C4A73),
                    fontWeight: actif ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}