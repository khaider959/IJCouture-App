import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/NoFirebase.dart';
import 'package:flutter_app/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {

    // return either the Home or Authenticate widget
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot){
        if(snapshot.hasError) {
          print('Cannot connect to firebase: ');
          return MaterialApp(
            home: NoFirebaseView(),
          );
        }
        if(snapshot.connectionState == ConnectionState.done) {
          print('Firebase connected');
          return  MaterialApp(
              home: MyApp(),
          );
        }

        return MaterialApp(
          home: WaitingFirebase(),
        );
      },
    );

  }
}