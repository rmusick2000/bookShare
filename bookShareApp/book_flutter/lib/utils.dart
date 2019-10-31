import 'package:flutter/material.dart';


makeActionButton( BuildContext context, buttonText, fn ) {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
   return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
         minWidth: MediaQuery.of(context).size.width - 30,
         padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
         onPressed: fn,
         child: Text( buttonText,
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                         color: Colors.white, fontWeight: FontWeight.bold)),
         )
      );
}

makeInputField( BuildContext context, hintText, obscure, controller ) {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   return TextField(
      obscureText: obscure,
      style: style,
      decoration: InputDecoration(
         contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
         hintText: hintText,
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
      controller: controller
      );
}
