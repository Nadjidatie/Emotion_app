import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  
  final String path;
  final double wight;
  final VoidCallback? onTap;

  const Square({super.key, required this.path, required this.wight, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding : EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color : Colors.grey),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200] // le gris est tamiser de 200
        ), 
        child : Row(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              path, 
              width: wight,
            ),
          ],
        ),
      ),
    );
  }
}