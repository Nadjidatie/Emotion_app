import 'package:emotion_app/services/cycleService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Bande horizontale de jours (style Flo) qui permet à l'utilisatrice de
/// marquer / démarquer chaque date comme "jour de règles".
///
/// Affiche 11 jours autour d'aujourd'hui (7 jours passés + aujourd'hui +
/// 3 jours à venir). Aujourd'hui est centré et entouré.
///
/// Réutilisable : le widget se contente d'appeler
/// [CycleService.marquerJourRegles] et de réécouter le service pour le
/// rendu — aucun état local.
class SelecteurJoursRegles extends StatefulWidget {
  /// Nombre de jours passés affichés (par défaut 7).
  final int joursPasses;

  /// Nombre de jours futurs affichés (par défaut 3).
  final int joursFuturs;

  const SelecteurJoursRegles({
    super.key,
    this.joursPasses = 7,
    this.joursFuturs = 3,
  });

  @override
  State<SelecteurJoursRegles> createState() => _SelecteurJoursReglesState();
}

class _SelecteurJoursReglesState extends State<SelecteurJoursRegles> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    CycleService.instance.addListener(_rafraichir);
    // Scroll initial : centrer approximativement sur "aujourd'hui".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final largeurChip = 56.0 + 10.0; // largeur + spacing
      _scrollController.jumpTo(
        widget.joursPasses * largeurChip -
            MediaQuery.of(context).size.width / 2 +
            largeurChip,
      );
    });
  }

  @override
  void dispose() {
    CycleService.instance.removeListener(_rafraichir);
    _scrollController.dispose();
    super.dispose();
  }

  void _rafraichir() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final aujourdhui = DateTime.now();
    final aujourdhuiJour = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day);
    final premier =
        aujourdhuiJour.subtract(Duration(days: widget.joursPasses));
    final total = widget.joursPasses + 1 + widget.joursFuturs;

    final jours = List.generate(
      total,
      (i) => premier.add(Duration(days: i)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8A0A0).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Color(0xFFE8A0A0),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes règles',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4C4A73),
                      ),
                    ),
                    Text(
                      'Appuie sur un jour pour le marquer',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8B87A3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: jours.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final jour = jours[i];
                final estAujourdhui = jour.year == aujourdhuiJour.year &&
                    jour.month == aujourdhuiJour.month &&
                    jour.day == aujourdhuiJour.day;
                return _ChipJour(
                  date: jour,
                  estAujourdhui: estAujourdhui,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipJour extends StatelessWidget {
  final DateTime date;
  final bool estAujourdhui;

  const _ChipJour({required this.date, required this.estAujourdhui});

  @override
  Widget build(BuildContext context) {
    final cycle = CycleService.instance;
    final marque = cycle.estJourReglesMarque(date);
    // Couleur tâche/prédite (sans tap) — un point pâle pour signaler les
    // jours prédits par le cycle.
    final estReglesPredit =
        !marque && cycle.estJourDeRegles(date);
    final estFutur = date.isAfter(DateTime.now());

    final jourSemaine = DateFormat('E', 'fr_FR')
        .format(date)
        .replaceAll('.', '')
        .toUpperCase();
    final jourNum = date.day.toString();

    return GestureDetector(
      onTap: estFutur && !marque
          ? null // pas de marquage futur (sauf si on veut un démarcage rapide)
          : () => cycle.marquerJourRegles(date, !marque),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56,
        decoration: BoxDecoration(
          color: marque
              ? const Color(0xFFE8A0A0)
              : (estReglesPredit
                  ? const Color(0xFFE8A0A0).withOpacity(0.18)
                  : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: estAujourdhui
                ? const Color(0xFFB79CED)
                : (marque
                    ? const Color(0xFFE8A0A0)
                    : const Color(0xFFE8DDF5)),
            width: estAujourdhui ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              jourSemaine.length > 3 ? jourSemaine.substring(0, 3) : jourSemaine,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: marque
                    ? Colors.white
                    : (estFutur
                        ? const Color(0xFF8B87A3)
                        : const Color(0xFF8B87A3)),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              jourNum,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    marque ? Colors.white : const Color(0xFF4C4A73),
              ),
            ),
            const SizedBox(height: 2),
            Icon(
              marque ? Icons.water_drop : Icons.water_drop_outlined,
              size: 10,
              color: marque
                  ? Colors.white
                  : (estReglesPredit
                      ? const Color(0xFFE8A0A0)
                      : const Color(0xFFE8DDF5)),
            ),
          ],
        ),
      ),
    );
  }
}
