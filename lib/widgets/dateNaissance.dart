import 'package:flutter/material.dart';

class Datenaissance extends StatelessWidget {

  final DateTime? value;
  final Function(DateTime) onChanged;

  const Datenaissance({super.key, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text("Date de naissance", style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4C4A73),
        ),),

        SizedBox(height: 8,),

        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );

            if (selectedDate != null) {
              onChanged(selectedDate);
            }


          },

          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              border: Border.all(color:  Color(0xFF4C4A73),),
              
            
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == null
                    ? "JJ/ MM / AAAA"
                    : "${value!.day.toString().padLeft(2, '0')} / ${value!.month.toString().padLeft(2, '0')} / ${value!.year}",
                  style: TextStyle(
                    fontSize: 15,
                    color: value == null
                        ? const Color(0xFFA09BB8)
                        : const Color(0xFF4C4A73),
                  ),
                  ),
                  
                  const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Color(0xFFA88BEF),
                ),
              ]
            )
              
          ),
        ),
      
      ],);
  }
}