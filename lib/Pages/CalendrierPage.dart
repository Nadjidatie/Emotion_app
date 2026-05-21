import 'package:emotion_app/model/cycle_phase.dart';
import 'package:emotion_app/model/journalQuotidien.dart';
import 'package:emotion_app/services/cycleService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'questionnairePage.dart';



/// Tap → fiche détaillée du jour avec score et symptômes.
class CalendrierPage extends StatefulWidget {
  const CalendrierPage({super.key});

  @override
  State<CalendrierPage> createState() => _CalendrierPageState();
}

class _CalendrierPageState extends State<CalendrierPage> {
  DateTime _moisCourant = DateTime.now();
  DateTime _jourSelectionne = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Quand un nouveau log est sauvegardé → rafraîchir le calendrier.
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

  bool _memeJour(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final cycle = CycleService.instance;
    final logSelectionne = cycle.logPour(_jourSelectionne);
    final phase = cycle.phasePour(_jourSelectionne);
    final phaseInfo = CyclePhaseInfo.of(phase);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF5FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4C4A73)),
        title: const Text(
          'Mon calendrier 🌸',
          style: TextStyle(
            color: Color(0xFF4C4A73),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // === LE CALENDRIER ===
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8DDF5)),
                ),
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  locale: 'fr_FR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _moisCourant,
                  selectedDayPredicate: (d) => _memeJour(d, _jourSelectionne),
                  calendarFormat: _format,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Mois',
                    CalendarFormat.twoWeeks: '2 semaines',
                    CalendarFormat.week: 'Semaine',
                  },
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _jourSelectionne = selected;
                      _moisCourant = focused;
                    });
                  },
                  onFormatChanged: (f) => setState(() => _format = f),
                  onPageChanged: (f) => _moisCourant = f,
                  headerStyle: HeaderStyle(
                    titleTextStyle: const TextStyle(
                      color: Color(0xFF4C4A73),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    formatButtonDecoration: BoxDecoration(
                      color: const Color(0xFFB79CED).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    formatButtonTextStyle:
                        const TextStyle(color: Color(0xFF4C4A73)),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF4C4A73),
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF4C4A73),
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Color(0xFF8B87A3),
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      color: Color(0xFF8B87A3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // === Cellules colorées ===
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) =>
                        _construireCellule(day, cycle, selectionne: false),
                    todayBuilder: (context, day, _) =>
                        _construireCellule(day, cycle,
                            selectionne: false, aujourdhui: true),
                    selectedBuilder: (context, day, _) =>
                        _construireCellule(day, cycle, selectionne: true),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // === LÉGENDE COULEURS ===
              _Legende(),

              const SizedBox(height: 16),

              // === FICHE DU JOUR SÉLECTIONNÉ ===
              _FicheJour(
                date: _jourSelectionne,
                phaseInfo: phaseInfo,
                log: logSelectionne,
                onRemplir: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuestionnairePage(date: _jourSelectionne),
                    ),
                  );
                  setState(() {}); // refresh fiche
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit une cellule colorée pour [day].
  Widget _construireCellule(
    DateTime day,
    CycleService cycle, {
    required bool selectionne,
    bool aujourdhui = false,
  }) {
    final log = cycle.logPour(day);
    final phase = cycle.phasePour(day);
    final estRegles =
        log?.estMenstruation ?? (phase == CyclePhase.menstruelle);

    final couleurFond = log?.couleurDuJour ?? const Color(0xFFF7F3FB);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: couleurFond,
        shape: BoxShape.circle,
        border: Border.all(
          color: selectionne
              ? const Color(0xFF4C4A73)
              : aujourdhui
                  ? const Color(0xFFB79CED)
                  : Colors.transparent,
          width: selectionne ? 2.5 : (aujourdhui ? 2 : 0),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: const Color(0xFF4C4A73),
              fontWeight: aujourdhui || selectionne
                  ? FontWeight.bold
                  : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (estRegles)
            Positioned(
              bottom: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8A0A0),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Légende des couleurs (réutilisable au cas où on l'affiche ailleurs).
class _Legende extends StatelessWidget {
  static const _entrees = [
    (Color(0xFFB79CED), 'Excellente'),
    (Color(0xFFD3BFF2), 'Bonne'),
    (Color(0xFFE8DDF5), 'Correcte'),
    (Color(0xFFEFE8F5), 'Difficile'),
    (Color(0xFFE0E0E0), 'Éprouvante'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Couleur du jour',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4C4A73),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: _entrees
                .map((e) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: e.$1,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          e.$2,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4C4A73),
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8A0A0),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Jour de règles',
                style: TextStyle(fontSize: 12, color: Color(0xFF8B87A3)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte récap pour le jour sélectionné dans le calendrier.
class _FicheJour extends StatelessWidget {
  final DateTime date;
  final CyclePhaseInfo phaseInfo;
  final JournalQuotidien? log;
  final VoidCallback onRemplir;

  const _FicheJour({
    required this.date,
    required this.phaseInfo,
    required this.log,
    required this.onRemplir,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatee =
        DateFormat('EEEE d MMMM y', 'fr_FR').format(date);
    final jourCycle = CycleService.instance.jourDuCycle(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DDF5)),
      ),
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
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(phaseInfo.icone, color: phaseInfo.couleur, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${phaseInfo.nom} · jour $jourCycle',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C4A73),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (log == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pas encore de questionnaire pour cette journée.',
                  style: TextStyle(color: Color(0xFF8B87A3)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRemplir,
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text('Remplir le questionnaire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB79CED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            )
          else
            _detailsLog(log!),
        ],
      ),
    );
  }

  Widget _detailsLog(JournalQuotidien log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: log.couleurDuJour,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${log.libelleScore} · ${log.scoreQuotidien.toStringAsFixed(1)}/10',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C4A73),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ligneStat('Humeur', log.humeur),
        _ligneStat('Sommeil', log.sommeil,
            extra: '${log.heuresSommeil.toStringAsFixed(1)} h'),
        _ligneStat('Stress', log.stress),
        _ligneStat('Énergie', log.energie),
        _ligneStat('Libido', log.libido),
        const SizedBox(height: 12),
        Text(
          'Activité : ${log.activite}',
          style: const TextStyle(color: Color(0xFF4C4A73)),
        ),
        if (log.symptomes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: log.symptomes
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DDF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4C4A73),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
        if (log.note != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '« ${log.note} »',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFF4C4A73),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onRemplir,
            icon: const Icon(Icons.edit, color: Color(0xFFB79CED)),
            label: const Text(
              'Modifier',
              style: TextStyle(color: Color(0xFFB79CED)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFB79CED)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ligneStat(String nom, double valeur, {String? extra}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              nom,
              style: const TextStyle(
                color: Color(0xFF8B87A3),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: valeur / 10,
                minHeight: 6,
                backgroundColor: const Color(0xFFE8DDF5),
                color: const Color(0xFFB79CED),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              extra ?? '${valeur.toStringAsFixed(1)}/10',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF4C4A73),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
