import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String title;
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  const Input( {
    super.key,
    required this.title,
    required this.label,
    required this.controller,
    this.obscureText = false,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
    
      children: [

        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4C4A73),
          ),
        ),

        SizedBox(height: 8,),
      
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF4C4A73),
          ),
          
          
            decoration: InputDecoration(
              //label: Text("$label", 
              label: Text(label,
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 187, 186, 188)
              ),),
              // hintText:  label,
              //hintStyle: TextStyle(
              //   fontSize: 14
              // ),

              contentPadding: EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
              
            

              filled: true, //  le champ avec une couleur
              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                ),

          
              ),




            ),
          
          validator: (value){
            if(value == null ||value.isEmpty){
              return "Veuillez entrer votre $label";
            }
            return null;
          },
        )
      ]
    );
    
  }
}
