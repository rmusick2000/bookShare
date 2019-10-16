import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text('Details Details')),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop( context );
          },
	child: Text( 'Go Back!'))));
  }
}
