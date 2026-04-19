import 'package:flutter/material.dart';

class SelectGenre extends StatelessWidget {
  final String? selected;
  final Function(String) onChanged;

  const SelectGenre({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildChoice(String value) {
      final isSelected = selected == value;

      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color.fromARGB(255, 195, 173, 250) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF4C4A73),
              ),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF7E7A9A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Genre",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4C4A73),
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4DDF0)),
          ),
          child: const Text(
            "Sélectionne ton genre :",
            style: TextStyle(
              color: Color(0xFFA09BB8),
              fontSize: 15,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            buildChoice("Homme"),
            const SizedBox(width: 8),
            buildChoice("Femme"),
            const SizedBox(width: 8),
            buildChoice("Autre"),
          ],
        ),
      ],
    );
  }
}