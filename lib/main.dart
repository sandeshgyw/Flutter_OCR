import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final imagepicker = ImagePicker();
  File selectedImage;
  String initialword = "";
  String secondWord = "";
  String decodedText = "";
  bool isImageLoaded = false;

  Future pickImage() async {
    var userImage = await imagepicker.getImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = File(userImage.path);
      isImageLoaded = true;
    });
  }

  Future readText() async {
    FirebaseVisionImage finalImage =
        FirebaseVisionImage.fromFile(selectedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(finalImage);
    print(readText.blocks);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          setState(() {
            secondWord = initialword + " " + word.text;
            initialword = secondWord;

            decodedText = secondWord;
          });
          print(secondWord);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          title: Text(
            'IMAGE TO TEXT',
            style: TextStyle(fontSize: 20),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 100.0),
            isImageLoaded
                ? Center(
                    child: Container(
                        height: 200.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 3),
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                                image: FileImage(selectedImage),
                                fit: BoxFit.cover))),
                  )
                : Container(),
            SizedBox(height: 10.0),
            FloatingActionButton.extended(
              label: Text('Select image'),
              onPressed: pickImage,
            ),
            SizedBox(height: 10.0),
            FloatingActionButton.extended(
              label: Text('Decode Image to Text'),
              onPressed: readText,
            ),
            SizedBox(
              height: 20,
            ),
            decodedText == ""
                ? SizedBox()
                : Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      initialValue: decodedText,
                      decoration: InputDecoration(
                        prefixStyle:
                            TextStyle(color: Colors.blue, fontSize: 16),
                        prefixIcon: Icon(
                          Icons.text_fields,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
          ],
        ));
  }
}
