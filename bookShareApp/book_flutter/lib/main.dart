//import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

void main() => runApp(BSApp());


class BSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( primarySwatch: Colors.green ),
      home:  BSHomePage(),
    );
  }
}


class BSHomePage extends StatefulWidget {
  BSHomePage({Key key}) : super(key: key);

  @override
  _BSHomePageState createState() => _BSHomePageState();
}


class _BSHomePageState extends State<BSHomePage> {


  
  @override
  Widget build(BuildContext context) {
    
    Color color = Theme.of(context).primaryColor;

    Widget _raisedButton = RaisedButton(
       child: Text('Login or Signup'),
       onPressed: () {
         Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookShareLoginPage()));
    });

    // XXX cleaner font for text
    // XXX richtext thins and color find, track and share
    // XXX no buttons -> clickable login text, how does it work text
    // XXX wide window buttons fall off bottom (no scroll).  narrow window image ends, shows blanks on top and bottom (color sizedBoxes?)
    Widget _nurb = Container(
       padding: const EdgeInsets.all(32),
       child: Text(
         'Share books with people you know.'
         'BookShare helps you Find, Track and Share books for any club you belong to.'
         'Create BookShare clubs for anything you love.. history, chinese language, or kite flying!',
         softWrap: true,
         style: new TextStyle( fontFamily: 'Mansalva', fontSize: 24.0)
          ));

    Widget _blurb = RichText(
       text: TextSpan(
          style: new TextStyle( fontFamily: 'Mansalva', fontSize: 24.0),
          children: [
             TextSpan( text: 'BookShare is an easy to use website for organizing a private library  ' ),
             TextSpan( text: 'between a small group of people.  With BookShare, you can add your own contributions '),
             TextSpan( text: 'to a library by scanning it with your phone.  You can also locate and request books '),
             TextSpan( text: 'in the library that currently reside with other members. <p> For example, a bookclub '),
             TextSpan( text: 'can use BookShare to keep track of who currently has which books on the reading list '),
             TextSpan( text: 'for the summer.<p>  For example, a language school typically has a very interested, '),
             TextSpan( text: 'active community of families, together with a rich but inaccessible trove of foreign '),
             TextSpan( text: 'language books.  Bookshare unlocks that treasure for the language school by making '),
             TextSpan( text: 'it easy to share and track any book that a participating member is willing to loan '),
             TextSpan( text: 'out to the community.')
             ]));

    // how does it work

    return Scaffold(
       body: Center(

         child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
               // Container( width: double.infinity, height: 100, child: Container( color: Colors.red)),
               Stack(
                  children: <Widget>[
                     Container( child: Image.asset( 'images/bookShare.jpeg', width: 1200,  fit: BoxFit.fitWidth)), 
                     Positioned( bottom: 200, left: 30, child: Text("BookShare", style: new TextStyle( fontFamily: 'Mansalva', fontSize: 70.0))),
                     Positioned( bottom: 30, left: 50, width: 700, child: _nurb )
                     ]),
               _raisedButton
               ]),
         
          )
      );

  }
}



