import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class Uploadpic extends StatefulWidget {
  @override
  _Uploadpic createState() => _Uploadpic();
}

class _Uploadpic extends State<Uploadpic>{
  late File imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purpleAccent,
      body: Center(
        child: imageFile == null ? Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/00.png'),
                  fit: BoxFit.cover)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 80),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),

                    ),
                    backgroundColor: Colors.pink,
                  ),
                  onPressed: () {
                    _getFromCamera();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            'Use camera',
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 20.0,
                                letterSpacing: -0.7,
                                fontFamily: 'OpenSansCondensed-Light'
                            )
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.camera_alt_outlined,
                          color: Colors.purple,)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Container(
                margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),

                    ),
                    backgroundColor: Colors.pink,
                  ),
                  onPressed: () {
                    _getFromGallery();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            'Upload from device',
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 20.0,
                                letterSpacing: -0.7,
                                fontFamily: 'OpenSansCondensed-Light'
                            )
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.file_upload,
                            color: Colors.purple),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40,),
              ElevatedButton(

                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),

                  ),
                  backgroundColor: Colors.pink,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/homefeed');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 30),
                  child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: Colors.purple,
                          fontSize: 20.0,
                          letterSpacing: -0.7,
                          fontFamily: 'OpenSansCondensed-Light'
                      )
                  ),
                ),
              ),
              SizedBox(height: 30,),

            ],

          ),
        )
            : Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/01.png'),
                  fit: BoxFit.cover)
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    )
                ),
              ),
              FloatingActionButton(
                child: Icon(Icons.backup_outlined),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                onPressed: () =>
                {
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
  }

  _getFromCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );

  }

}