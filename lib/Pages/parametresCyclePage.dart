import 'package:emotion_app/model/cycle_phase.dart';
import 'package:emotion_app/services/cycleService.dart';
import 'package:emotion_app/widgets/stepperNumerique.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Écran de paramétrage du cycle.
///
/// L'utilisatrice peut :
///  - choisir la date du début de ses dernières règles,
///  - ajuster la longueur moyenne de son cycle (21-40 jours),
///  - ajuster la durée moyenne de ses règles (2-10 jours).
///
/// Une prévisualisation en bas montre en direct la phase courante et la
/// prochaine date de règles à partir des valeurs saisies. Le bouton
/// "Enregistrer" appelle [CycleService.definirParametresCycle].
class ParametresCyclePage extends StatefulWidget {
  const ParametresCyclePage({super.key});

  @override
  State<ParametresCyclePage> createState() => _ParametresCyclePageState();
}

class _ParametresCyclePageState extends State<ParametresCyclePage> {
  late DateTime _dernieresRegles;
  late int _longueurCycle;
  late int _dureeRegles;
  bool _sauvegardeEnCours = false;

  // Bornes raisonnables pour les steppers.
  static const _minCycle = 21;
  static const _maxCycle = 40;
  static const _minDureeRegles = 2;
  static const _maxDureeRegles = 10;

  @override
  void initState() {
    super.initState();
    final cycle = CycleService.instance;
    _dernieresRegles = cycle.dernieresRegles;
    _longueurCycle = cycle.longueurCycle;
    _dureeRegles = cycle.dureeRegles;
  }

  Future<void> _choisirDate() async {
    final aujourdhui = DateTime.now();
    final choisie = await showDatePicker(
      context: context,
      locale: const Locale('fr', 'FR'),
      initialDate: _dernieresRegles,
      // On accepte jusqu'à 6 mois en arrière → suffisant pour rattraper
      // un cycle non logué, sans permettre des dates absurdes.
      firstDate: aujourdhui.subtract(const Duration(days: 180)),
      lastDate: aujourdhui,
      helpText: 'Début de tes dernières règles',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFB79CED),
            onPrimary: Colors.white,
            onSurface: Color(0xFF4C4A73),
          ),
        ),
        child: child!,
      ),
    );
    if (choisie != null) {
      setState(() => _dernieresRegles = choisie);
    }
  }

  Future<void> _sauvegarder() async {
    setState(() => _sauvegardeEnCours = true);
    try {
      await CycleService.instance.definirParametresCycle(
        dernieresRegles: _dernieresRegles,
        longueurCycle: _longueurCycle,
        dureeRegles: _dureeRegles,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFB79CED),
          content: Text(
            'Paramètres du cycle enregistrés 🌸',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _sauvegardeEnCours = false);
    }
  }

  // === Prévisualisation calculée en local ====================================
  // On reproduit le calcul de CycleService pour montrer en direct l'effet
  // des nouveaux paramètres, avant même de sauvegarder.

  int _jourDuCycleApercu(DateTime date) {
    final diff = _dateOnly(date)
        .difference(_dateOnly(_dernieresRegles))
        .inDays;
    if (diff < 0) {
      final reste = diff % _longueurCycle;
      return reste == 0 ? _longueurCycle : _longueurCycle + reste;
    }
    return (diff % _longueurCycle) + 1;
  }

  CyclePhase _phaseApercu(DateTime date) {
    final jour = _jourDuCycleApercu(date);
    if (jour <= _dureeRegles) return CyclePhase.menstruelle;
    final jourOvulation = _longueurCycle - 14;
    if (jour < jourOvulation) return CyclePhase.folliculaire;
    if (jour <= jourOvulation + 2) return CyclePhase.ovulatoire;
    return CyclePhase.luteale;
  }

  DateTime _prochainesReglesApercu() {
    final aujourdhui = _dateOnly(DateTime.now());
    final jour = _jourDuCycleApercu(aujourdhui);
    final restant = _longueurCycle - jour + 1;
    return aujourdhui.add(Duration(days: restant));
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final aujourdhui = DateTime.now();
    final phaseAct = _phaseApercu(aujourdhui);
    final infoPhase = CyclePhaseInfo.of(phaseAct);
    final jourActuel = _jourDuCycleApercu(aujourdhui);
    final prochaines = _prochainesReglesApercu();
    final joursAvant = prochaines
        .difference(_dateOnly(aujourdhui))
        .inDays;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF5FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4C4A73)),
        title: const Text(
          'Paramètres du cycle',
          style: TextStyle(
            color: Color(0xFF4C4A73),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const _IntroBandeau(),
            const SizedBox(height: 20),

            // === Dernières règles (date picker) ===
            _Carte(
              titre: 'Début de tes dernières règles',
              sousTitre: 'Sert de référence pour calculer la phase courante',
              icone: Icons.water_drop,
              couleurAccent: const Color(0xFFE8A0A0),
              child: GestureDetector(
                onTap: _choisirDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCF5FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8DDF5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFFB79CED), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                              .format(_dernieresRegles),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4C4A73),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.edit,
                          color: Color(0xFF8B87A3), size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // === Longueur du cycle ===
            _Carte(
              titre: 'Longueur moyenne du cycle',
              sousTitre: 'Du 1ᵉʳ jour des règles au 1ᵉʳ jour des suivantes',
              icone: Icons.autorenew,
              couleurAccent: const Color(0xFFB79CED),
              child: StepperNumerique(
                valeur: _longueurCycle,
                min: _minCycle,
                max: _maxCycle,
                suffixe: ' jours',
                onChanged: (v) => setState(() => _longueurCycle = v),
              ),
            ),
            const SizedBox(height: 14),

            // === Durée des règles ===
            _Carte(
              titre: 'Durée moyenne de tes règles',
              sousTitre: 'Combien de jours dure ta phase menstruelle',
              icone: Icons.timelapse,
              couleurAccent: const Color(0xFFD88FB5),
              child: StepperNumerique(
                valeur: _dureeRegles,
                min: _minDureeRegles,
                max: _maxDureeRegles,
                suffixe: ' jours',
                onChanged: (v) => setState(() => _dureeRegles = v),
              ),
            ),
            const SizedBox(height: 18),

            // === Aperçu live ===
            _Apercu(
              infoPhase: infoPhase,
              jour: jourActuel,
              longueurCycle: _longueurCycle,
              prochaines: prochaines,
              joursAvant: joursAvant,
            ),
            const SizedBox(height: 20),

            // === Bouton Enregistrer ===
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _sauvegardeEnCours ? null : _sauvegarder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB79CED),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFFB79CED).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _sauvegardeEnCours
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Enregistrer',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Sous-widgets internes (privés, propres à ce fichier).
// ===========================================================================

class _IntroBandeau extends StatelessWidget {
  const _IntroBandeau();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFB79CED).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF4C4A73), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ces réglages servent à calculer ta phase actuelle et à prédire '
              'tes prochaines règles. Tu peux les modifier à tout moment.',
              style: TextStyle(fontSize: 12, color: Color(0xFF4C4A73)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Carte extends StatelessWidget {
  final String titre;
  final String? sousTitre;
  final IconData icone;
  final Color couleurAccent;
  final Widget child;

  const _Carte({
    required this.titre,
    required this.icone,
    required this.couleurAccent,
    required this.child,
    this.sousTitre,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: couleurAccent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: couleurAccent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4C4A73),
                      ),
                    ),
                    if (sousTitre != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sousTitre!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8B87A3),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Apercu extends StatelessWidget {
  final CyclePhaseInfo infoPhase;
  final int jour;
  final int longueurCycle;
  final DateTime prochaines;
  final int joursAvant;

  const _Apercu({
    required this.infoPhase,
    required this.jour,
    required this.longueurCycle,
    required this.prochaines,
    required this.joursAvant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            infoPhase.couleur,
            infoPhase.couleur.withOpacity(0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(infoPhase.icone,
                    color: infoPhase.couleur, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aperçu (jour $jour / $longueurCycle)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      infoPhase.nom,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  joursAvant > 0
                      ? 'Prochaines règles dans $joursAvant j (${DateFormat('d MMM', 'fr_FR').format(prochaines)})'
                      : 'Tes règles sont prévues aujourd\'hui',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
