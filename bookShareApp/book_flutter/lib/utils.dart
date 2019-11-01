import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void notYetImplemented(BuildContext context) {
   Fluttertoast.showToast(
      msg: "Future feature",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.pinkAccent,
      textColor: Colors.white,
      fontSize: 14.0
      );
}

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

/// Flutter icons customIcons
/// Copyright (C) 2019 by original authors @ fluttericon.com, fontello.com
/// This font was generated by FlutterIcon.com, which is derived from Fontello.

class customIcons {
  customIcons._();

  static const _kFontFam = 'customIcons';

  static const IconData home = const IconData(0xe800, fontFamily: _kFontFam);
  static const IconData home_here = const IconData(0xe801, fontFamily: _kFontFam);
  static const IconData loan = const IconData(0xe802, fontFamily: _kFontFam);
  static const IconData loan_here = const IconData(0xe803, fontFamily: _kFontFam);
  static const IconData profile = const IconData(0xe804, fontFamily: _kFontFam);
  static const IconData profile_here = const IconData(0xe805, fontFamily: _kFontFam);
  static const IconData search = const IconData(0xe806, fontFamily: _kFontFam);
  static const IconData search_here = const IconData(0xe807, fontFamily: _kFontFam);
  static const IconData book_shelf = const IconData(0xe80a, fontFamily: _kFontFam);
  static const IconData book_shelf_here = const IconData(0xe80b, fontFamily: _kFontFam);
  static const IconData add_book = const IconData(0xe80f, fontFamily: _kFontFam);
  static const IconData add_book_here = const IconData(0xe810, fontFamily: _kFontFam);
}
