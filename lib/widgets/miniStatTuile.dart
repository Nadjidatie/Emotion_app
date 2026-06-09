import 'package:flutter/material.dart';

class MiniStatTuile extends StatelessWidget {
  final String valeur;
  final String libelle;
  final IconData icone;
  final Color couleur;

  const MiniStatTuile({
    super.key,
    required this.valeur,
    required this.libelle,
    required this.icone,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  libelle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B87A3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: couleur.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: couleur, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valeur,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4C4A73),
            ),
          ),
        ],
      ),
    );
  }
}