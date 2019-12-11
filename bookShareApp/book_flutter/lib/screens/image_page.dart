import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:convert'; 

import 'package:image_crop/image_crop.dart';

import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/app_state_container.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/utils_load.dart';
import 'package:bookShare/models/books.dart';
import 'package:bookShare/models/libraries.dart';

// NOTE incoming scale is crop area / image area.  So, at max crop, if image is rectangular, scale will be < 1.  no work here.
// NOTE area represents original request, not resulting crop zone.  So, need to rectify values outside [0,1]
// NOTE area is in percentages, so no need to understand original cropping Container size.  work from convertedNI directly.
// image is the original network image, not the post-scaled one.  crop percentages applied here, then scaled to dstSize
class libPainter extends CustomPainter {
   final ui.Image image;
   final Rect     area;
   final double   scale;
   final double   dstSize;
   AppState appState;
   
   libPainter({this.image, this.area, this.scale, this.dstSize, this.appState});

   @override
   void paint(Canvas canvas, Size size) {

      double left  = area.left;
      double right = area.right;
      double top   = area.top;
      double bot   = area.bottom;
      // Rectify for rebounding crop zone
      if( left < 0 ) {
         right = min( 1.0, right - left);   // crop bounce back
         left = 0.0;
      }
      if( right > 1.0 ) {
         left = max( 0.0, left - (right - 1.0));   
         right = 1.0;
      }
      if( top < 0 ) {
         bot = min( 1.0, bot - top);
         top = 0.0;
      }
      if( bot > 1.0 ) {
         top = max( 0.0, top - ( bot - 1.0));
         bot = 1.0;
      }
        
      // Create source rect
      final leftPix  = left * image.width;
      final rightPix = right * image.width;
      final topPix   = top * image.height;
      final botPix   = bot * image.height;

      _drawCanvas( canvas ) {
         final List<Color> colors = [];
         canvas.drawAtlas(
            image,
            [
               RSTransform.fromComponents(
                  rotation: 0.0,
                  scale: dstSize / (rightPix - leftPix),
                  anchorX: 0.0,
                  anchorY: 0.0,
                  translateX: 0.0,
                  translateY: 0.0)
               ],
            [
               // the source rectangle within the image 
               Rect.fromLTRB(leftPix, topPix, rightPix, botPix )
               ],
            colors, 
            BlendMode.src, 
            null,  // cullRect
            Paint());
      }

     _drawCanvas( canvas );

     // 'Record' current canvas to image.
     // Note: Paint gets called 5-10x per crop.  just do this once.
     if( appState.makeLibPng ) {
        print( "Making png data" );
        ui.PictureRecorder recorder = ui.PictureRecorder();
        Canvas canvasRec = Canvas(recorder);
        _drawCanvas( canvasRec );
        final picture  = recorder.endRecording();
        makePngBytes( appState, picture, dstSize.floor(), dstSize.floor() );
        appState.makeLibPng = false;
     }
  }

  @override
  bool shouldRepaint(libPainter oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(libPainter oldDelegate) => false;
}


class BookShareImagePage extends StatefulWidget {
   BookShareImagePage({Key key}) : super(key: key);

   @override
      _BookShareImagePageState createState() => _BookShareImagePageState(); 
}

class _BookShareImagePageState extends State<BookShareImagePage> {

   // Parameter passed along in navigator
   Library editLibrary; 
   var container;
   AppState appState;

   String selector;             // What should I be viewing in main viewport
   var selectedImage;           // an image has been chosen
   String selectedType;         // network?  blob?  asset?
   bool newSelection;           // used to force cropping, avoiding a race condition with first preview

   bool imageConverted;         // true once selected network image has converted to ui.image
   ui.Image convertedNI;        // converted networkImage
   
   var croppedImage;            // i b croppy 
   var cropKey;                 // the main access point to crop data
   bool updatePreview;          // is it time to update the preview image?  very brief lifespan
   Widget preview;              // the current preview
   
   @override
   void initState() {
      super.initState();
      selector = "";

      selectedImage = null;
      selectedType = "";
      newSelection = false;

      imageConverted = false;
      convertedNI = null;

      croppedImage = null;
      cropKey = null;

      updatePreview = false;
      preview = Container();
   }

   @override
   void dispose() {
      super.dispose();
   }

   // Try converting network image to image
   // XXX just do this with future, remove completer.
   _getImage( selectedImage ) async {

      Completer<ImageInfo> completer = Completer();

      Future<ui.Image> getImage(String selectedImage) async {
         var img = new NetworkImage(selectedImage);
         img.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info,bool _){
                  completer.complete(info);
               }));
         ImageInfo imageInfo = await completer.future;
         return imageInfo.image;
      }
      var tmp = await getImage( selectedImage );

      convertedNI = tmp;
      print( "SETSTATE getImage imageConverted" );
      setState(() => imageConverted = true );
   }
   

   Widget _makeCoverChunk( book ) {
      final imageHeight = appState.screenHeight * .36;
      final imageWidth  = imageHeight;
     
      var image;
      if( book.image != "---" ) { image = Image.network( book.image, height: imageHeight, width: imageWidth, fit: BoxFit.contain ); }
      else                      { return null; }
      
      return GestureDetector(
         onTap:  () async
         {
            // re-init for new image
            newSelection = true;
            imageConverted = false;
            if( cropKey != null ) { cropKey.currentState = null; }
            convertedNI = null;
            croppedImage = null;
            
            selectedImage = book.image;
            selectedType  = "network";
            await _getImage( selectedImage );
            print( "SETSTATE CoverChunkTap selector" );
            setState(() => selector = "image" );
         },
         child: ClipRRect( borderRadius: new BorderRadius.circular(12.0), child: image )
         );
   }

   Widget _cropImage( image, imageHeight, imageWidth ) {
      cropKey = GlobalKey<CropState>();
      Widget _buildCropImage() {
         return Container(
            color: Colors.black,
            height: imageHeight,
            width:  imageWidth,
            padding: const EdgeInsets.all(0.0),
            child: Crop(
               key: cropKey,
               image: new NetworkImage( selectedImage ),
               aspectRatio: 1.0 / 1.0,
               ));
      }

      return Listener(
         onPointerUp: _updatePreview,
         child: _buildCropImage()
         );
   }

   // NOTE what you get back here is the request, not the grant.  for example, if you drag book to left, L boundary will
   //      show negative, even though rebounded crop is back to L = 0
   _updatePreview( PointerEvent details ) {
      if( cropKey != null && cropKey.currentState != null ) {
         print( "SETSTATE updatePreview updatePreview" );
         setState(() => updatePreview = true );
         appState.makeLibPng = true;
      } 
   }

   
   Widget _makePreview() {
      final previewHeight = appState.screenHeight * .1014;

      preview = Container(
         decoration: BoxDecoration( border: Border.all( width: 4.0, color: Colors.pinkAccent ) ),
         height: previewHeight,
         width: previewHeight );

      if( updatePreview && ! ( cropKey == null || cropKey.currentState == null ) ) {
         // print( "makePreview: paint " + updatePreview.toString() + " " + imageConverted.toString());
         final scale = cropKey.currentState.scale;
         final area = cropKey.currentState.area;
         
         if( imageConverted ) {
            preview = Container(
               height: previewHeight,
               width: previewHeight,
               child: CustomPaint(
                  painter: libPainter(
                     image: convertedNI,
                     area: area,
                     scale: scale,
                     dstSize: previewHeight,
                     appState: appState
                     )
                  ));
            updatePreview = false;
            newSelection = false;
         }
      }
      return preview;
   }
   
   Widget _makeImageView( imageHeight ) {
      final imageWidth = appState.screenWidth * .8;

      // avoid unhelpful crop reset
      if( !(updatePreview && cropKey != null && cropKey.currentState != null )) {
         var image;
         if( selectedType == "network" ) { image = Image.network( selectedImage, height: imageHeight, width: imageWidth, fit: BoxFit.contain ); }

         print( "makeImageView, about to crop" );
         Widget cropper = _cropImage( image, imageHeight, imageWidth );
         croppedImage = cropper ?? image;
      }
      
      return Row( 
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
         children: <Widget>[
            croppedImage,
            _makePreview()
            ]);
   }

   Widget _makeGridView( ) {

      List<Widget> coverChunks = [];
      if( appState.booksInLib == null ) { return Container(); }
      
      List<Book> bil = appState.booksInLib[appState.privateLibId];
      if( bil == null ) { return Container(); }
      bil.forEach((book) {
            final Widget chunk = _makeCoverChunk( book );
            if( chunk != null ) { coverChunks.add( chunk ); }
         });

      return GridView.count(
         primary: false,
         scrollDirection: Axis.vertical,
         padding: const EdgeInsets.all(0),
         crossAxisSpacing: 0,
         mainAxisSpacing: 12,
         crossAxisCount: 3,
         children: coverChunks
         );
   }
   
   Widget _makeSourceRow() {
      final iconHeight = appState.screenHeight * .05;
      return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
            Row( 
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: <Widget>[
                  Padding(
                     padding: EdgeInsets.fromLTRB( 0, 4, 0, 0),
                     child: Text( "Select image source:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(0,0,0,0),
                     child: GestureDetector( 
                        onTap:  ()
                        {
                           print( "Open camera " + editLibrary.id);
                           print( "SETSTATE makeSourceRow selector" );
                           setState(() => selector = "camera" );

                        },
                        child: Icon( Icons.camera, size: iconHeight )
                        )),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(0,0,0,0),
                     child: GestureDetector( 
                        onTap:  ()
                        {
                           print( "Open gallery " + editLibrary.id);
                           print( "SETSTATE makeSourceRow selector" );
                           setState(() => selector = "gallery" );
                        },
                        child: Icon( Icons.collections, size: iconHeight )
                        )),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(0,0,0,0),
                     child: GestureDetector( 
                        onTap:  ()
                        {
                           print( "Open bookgrid " + editLibrary.id);
                           print( "SETSTATE makeSourceRow selector" );
                           setState(() => selector = "covers" );
                        },
                        child: Icon( Icons.local_library, size: iconHeight )
                        )),

                  ]),
            ]);
   }

   Widget _makeContent( imageHeight ) {
      Widget content;
      if( selector == "covers" )     { content = _makeGridView(); }
      else if( selector == "image" ) { content = _makeImageView( imageHeight ); }
      else                           { content = Container();  imageHeight = .001*imageHeight;   }

      return SizedBox( height: imageHeight, child: content );
   }

   Widget _makeHeader( imageHeight ) {
      if( selector == "" ) { return Container( height: imageHeight * .3 ); }
      else                 { return Container( height: imageHeight * .04 ); }
   }

   Widget _makeDivider() {
      if( selector == "" ) { return Container(); }
      else                 { return Divider( color: Colors.grey[200], thickness: 3.0 ); }
   }
   

   // Save the image to dynamo, pop back
   _acceptCrop() async {

      final crop = cropKey.currentState;
      if( !newSelection ) {
         // Save image  
         assert( appState.currentPng != null );

         print( "Set image, imagePng for lib: " + editLibrary.id );
         editLibrary.imagePng = appState.currentPng;
         editLibrary.image    = Image.memory( appState.currentPng );
         
         print( "SETSTATE acceptCrop updateLibs" );
         setState(() => appState.updateLibs = true );
         Navigator.pop(context);
      } else {
         showToast( context, "Oops, forgot to crop image" );
      }
   }
   
   Widget _makeButtons( imageHeight ) {
      final buttons = Row( 
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.end,
         children: <Widget>[
            Padding(
               padding: EdgeInsets.fromLTRB(0,6,0,imageHeight * .03),
               child: makeActionButtonSmall(
                  appState,
                  "Accept",
                  () async { _acceptCrop();  })),
            Padding(
               padding: EdgeInsets.fromLTRB(12,6,12,imageHeight * .03),
               child: makeActionButtonSmall(
                  appState,
                  "Cancel",
                  () async { Navigator.pop(context); })),
            ]);

      if( selector == "" ) { return Container(); }
      else                 { return buttons; }
   }

   @override
   Widget build(BuildContext context) {
   
      editLibrary = ModalRoute.of(context).settings.arguments;
      container   = AppStateContainer.of(context);
      appState    = container.state;

      final imageHeight = appState.screenHeight * .73;
      final imageWidth  = imageHeight * .913;

      assert( editLibrary != null );

      print( "build image page" );

      return Scaffold(
         appBar: PreferredSize(
            preferredSize: Size.fromHeight( appState.screenHeight*.001 ),
            child: AppBar( leading: Container() )),
         body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
               _makeHeader( imageHeight ), 
               _makeSourceRow(),
               _makeDivider(),
               _makeContent( imageHeight ),
               _makeButtons( imageHeight )
               ])
         );
   }
}

        

