import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cycle_phase.dart';
import '../models/daily_log.dart';
import '../services/cycle_service.dart';
import '../widgets/chipsQuestion.dart';
import '../widgets/menstruationToggle.dart';
import '../widgets/questionCard.dart';
import '../widgets/sliderQuestion.dart';

/// Questionnaire quotidien.
///
/// Étape 3 du cahier des charges : "Sauvegarder" insère un [DailyLog] dans
/// [CycleService] (stockage en mémoire). À l'étape 4, on remplacera juste le
/// corps de [_sauvegarder] par un appel Supabase, le reste de l'écran ne
/// bougera pas.
class QuestionnairePage extends StatefulWidget {
  /// Date pour laquelle on remplit le questionnaire.
  /// Par défaut : aujourd'hui.
  final DateTime? date;

  const QuestionnairePage({super.key, this.date});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  late final DateTime _date;

  // Valeurs initiales (préchargées depuis un log existant si disponible).
  double _humeur = 5;
  double _sommeil = 5;
  double _stress = 5;
  double _energie = 5;
  double _libido = 5;
  double _heuresSommeil = 7;
  bool _estMenstruation = false;
  String _activite = 'Aucun';
  List<String> _symptomes = [];
  final TextEditingController _noteController = TextEditingController();

  static const _activites = [
    'Aucun',
    'Marche',
    'Yoga',
    'Cardio',
    'Musculation',
  ];

  static const _symptomesDisponibles = [
    'Crampes',
    'Maux de tête',
    'Fatigue',
    'Ballonnements',
    'Acné',
    'Douleurs poitrine',
    'Sautes d\'humeur',
    'Libido haute',
    'Énergique',
    'Anxiété',
  ];

  @override
  void initState() {
    super.initState();
    _date = widget.date ?? DateTime.now();
    final existant = CycleService.instance.logPour(_date);
    if (existant != null) {
      _humeur = existant.humeur;
      _sommeil = existant.sommeil;
      _stress = existant.stress;
      _energie = existant.energie;
      _libido = existant.libido;
      _heuresSommeil = existant.heuresSommeil;
      _estMenstruation = existant.estMenstruation;
      _activite = existant.activite;
      _symptomes = List.of(existant.symptomes);
      _noteController.text = existant.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _sauvegarder() {
    final log = DailyLog(
      date: _date,
      humeur: _humeur,
      sommeil: _sommeil,
      stress: _stress,
      energie: _energie,
      libido: _libido,
      heuresSommeil: _heuresSommeil,
      estMenstruation: _estMenstruation,
      activite: _activite,
      symptomes: _symptomes,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    CycleService.instance.sauvegarderLog(log);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFFB79CED),
        content: Text(
          'Questionnaire sauvegardé 🌸',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
    Navigator.pop(context, log);
  }

  @override
  Widget build(BuildContext context) {
    final phase = CycleService.instance.phasePour(_date);
    final phaseInfo = CyclePhaseInfo.of(phase);
    final dateFormatee =
        DateFormat('EEEE d MMMM', 'fr_FR').format(_date);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF5FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4C4A73)),
        title: const Text(
          'Comment te sens-tu ? 🌸',
          style: TextStyle(
            color: Color(0xFF4C4A73),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                child: Column(
                  children: [
                    // Bandeau date + phase
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: phaseInfo.couleur.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(phaseInfo.icone, color: phaseInfo.couleur),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateFormatee,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF8B87A3),
                                  ),
                                ),
                                Text(
                                  phaseInfo.nom,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4C4A73),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Humeur
                    QuestionCard(
                      titre: 'Comment est ton humeur aujourd\'hui ?',
                      icone: Icons.sentiment_satisfied_alt,
                      child: SliderQuestion(
                        valeur: _humeur,
                        labelMin: 'Très basse',
                        labelMax: 'Très haute',
                        onChanged: (v) => setState(() => _humeur = v),
                      ),
                    ),

                    // Sommeil — qualité
                    QuestionCard(
                      titre: 'Qualité du sommeil',
                      icone: Icons.bedtime,
                      child: SliderQuestion(
                        valeur: _sommeil,
                        labelMin: 'Mauvais',
                        labelMax: 'Excellent',
                        onChanged: (v) => setState(() => _sommeil = v),
                      ),
                    ),

                    // Sommeil — heures
                    QuestionCard(
                      titre: 'Heures de sommeil',
                      icone: Icons.access_time,
                      child: SliderQuestion(
                        valeur: _heuresSommeil,
                        min: 0,
                        max: 12,
                        divisions: 24,
                        labelMin: '0 h',
                        labelMax: '12 h',
                        formatValeur: (v) => '${v.toStringAsFixed(1)} h',
                        onChanged: (v) => setState(() => _heuresSommeil = v),
                      ),
                    ),

                    // Stress
                    QuestionCard(
                      titre: 'Niveau de stress',
                      icone: Icons.bolt,
                      child: SliderQuestion(
                        valeur: _stress,
                        labelMin: 'Aucun',
                        labelMax: 'Très élevé',
                        couleur: const Color(0xFFE8A0A0),
                        onChanged: (v) => setState(() => _stress = v),
                      ),
                    ),

                    // Énergie
                    QuestionCard(
                      titre: 'Niveau d\'énergie',
                      icone: Icons.local_fire_department,
                      child: SliderQuestion(
                        valeur: _energie,
                        labelMin: 'Épuisée',
                        labelMax: 'Pleine d\'énergie',
                        couleur: const Color(0xFFF5C97E),
                        onChanged: (v) => setState(() => _energie = v),
                      ),
                    ),

                    // Libido
                    QuestionCard(
                      titre: 'Libido',
                      icone: Icons.favorite,
                      child: SliderQuestion(
                        valeur: _libido,
                        labelMin: 'Faible',
                        labelMax: 'Forte',
                        couleur: const Color(0xFFD88FB5),
                        onChanged: (v) => setState(() => _libido = v),
                      ),
                    ),

                    // Activité physique (chips, sélection unique)
                    QuestionCard(
                      titre: 'Activité physique',
                      sousTitre: 'Sélectionne ce que tu as pratiqué',
                      icone: Icons.directions_run,
                      child: ChipsQuestion(
                        options: _activites,
                        selection: [_activite],
                        multiSelection: false,
                        onChanged: (s) => setState(
                            () => _activite = s.isEmpty ? 'Aucun' : s.first),
                      ),
                    ),

                    // Symptômes (chips, multi-sélection)
                    QuestionCard(
                      titre: 'Symptômes ressentis',
                      sousTitre: 'Plusieurs choix possibles',
                      icone: Icons.healing,
                      child: ChipsQuestion(
                        options: _symptomesDisponibles,
                        selection: _symptomes,
                        multiSelection: true,
                        onChanged: (s) => setState(() => _symptomes = s),
                      ),
                    ),

                    // Règles ?
                    QuestionCard(
                      titre: 'Règles aujourd\'hui ?',
                      icone: Icons.water_drop,
                      child: MenstruationToggle(
                        valeur: _estMenstruation,
                        onChanged: (v) => setState(() => _estMenstruation = v),
                      ),
                    ),

                    // Note libre
                    QuestionCard(
                      titre: 'Note personnelle',
                      sousTitre: 'Optionnel — quelque chose à noter ?',
                      icone: Icons.edit_note,
                      child: TextField(
                        controller: _noteController,
                        maxLines: 3,
                        style: const TextStyle(color: Color(0xFF4C4A73)),
                        decoration: InputDecoration(
                          hintText: 'Ex : journée intense au travail...',
                          hintStyle:
                              const TextStyle(color: Color(0xFF8B87A3)),
                          filled: true,
                          fillColor: const Color(0xFFFCF5FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFFE8DDF5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8DDF5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFB79CED),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB79CED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: _sauvegarder,
            child: const Text(
              'Sauvegarder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
