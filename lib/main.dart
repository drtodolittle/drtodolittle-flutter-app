// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'todo_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dr ToDo Little',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<FirebaseUser>(
        future: _handleSignIn(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (!snapshot.hasData) {
              // while data is loading:
              return Center(
                child: CircularProgressIndicator(),
              );
          } else {
              // data loaded:
              final user = snapshot.data;
              Firestore.instance.collection('users').document(user.uid).get()
                .then((docRef) {
                  if (!docRef.exists){
                    Firestore.instance.collection('users').document(user.uid).setData({'email':user.email});
                  }
                });

              return ToDoPage(
                title: 'Dr ToDo Little',
                user: user,
              );  
          }
           
        } 
      ),
      
    );
  }


  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }


}
