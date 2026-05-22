import 'package:flutter/material.dart';
import 'package:emotion_app/model/cycle_phase.dart';
import 'package:emotion_app/services/cycleService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cycle_phase.dart';


class PhaseActuelle  extends StatefulWidget {
  final VoidCallback? onTapQuestionnaire;

  const PhaseActuelle ({super.key, this.onTapQuestionnaire});

  @override
    State<PhaseActuelle > createState() => _PhaseActuelleState();
  }

class _PhaseActuelleState extends State<PhaseActuelle > {
  @override
  void initState() {
    super.initState();
    CycleService.instance.addListener(_rafraichir);
  }

  @override
  void dispose() {
    CycleService.instance.removeListener(_rafraichir);
    super.dispose();
  }

  void _rafraichir() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cycle = CycleService.instance;
    final aujourdhui = DateTime.now();
    final phase = cycle.phasePour(aujourdhui);
    final info = CyclePhaseInfo.of(phase);
    final jour = cycle.jourDuCycle(aujourdhui);
    final prochaines = cycle.prochainesRegles();
    final joursAvantRegles =
        prochaines.difference(DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day)).inDays;
    final aDejaRempli = cycle.logPour(aujourdhui) != null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            info.couleur.withOpacity(0.85),
            info.couleur.withOpacity(0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: info.couleur.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(info.icone, color: info.couleur, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jour $jour de ton cycle',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      info.nom,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            info.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info.conseil,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                joursAvantRegles > 0
                    ? 'Prochaines règles dans $joursAvantRegles j (${DateFormat('d MMM', 'fr_FR').format(prochaines)})'
                    : 'Tes règles sont prévues aujourd\'hui',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onTapQuestionnaire,
              icon: Icon(
                aDejaRempli ? Icons.check_circle : Icons.edit_note,
                color: info.couleur,
              ),
              label: Text(
                aDejaRempli
                    ? 'Modifier le questionnaire'
                    : 'Remplir le questionnaire du jour',
                style: TextStyle(
                  color: info.couleur,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
