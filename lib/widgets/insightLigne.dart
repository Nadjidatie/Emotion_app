import 'package:flutter/material.dart';

class InsightLigne extends StatelessWidget {
  final String emoji;
  final String texte;

  const InsightLigne({
    super.key,
    required this.emoji,
    required this.texte,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texte,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4C4A73),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}