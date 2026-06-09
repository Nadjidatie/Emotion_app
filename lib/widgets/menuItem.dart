import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String texte;
  final bool isSelected;
  final VoidCallback? onTap;
  const MenuItem({
    super.key,
    required this.icon,
    required this.texte,
    this.isSelected = false,
    this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected? Color(0xFFB79CED) : Colors.grey,
            size : 26,
          ),

          SizedBox(height: 4,),

          Text(
            texte,
            style: TextStyle(
              fontSize: 12,
              color: isSelected? Color(0xFFB79CED) : Colors.grey,
              fontWeight: isSelected? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
      
    );
  }
}
