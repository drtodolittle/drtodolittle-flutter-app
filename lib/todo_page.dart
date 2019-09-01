// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/foundation/diagnostics.dart';

class ToDoPage extends StatelessWidget {
  ToDoPage({Key key, this.title, this.user});

  final FirebaseUser user;
  final String title;

  static const String routeName = '/todo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ToDoList(user),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddToDoPage(user: user,)),);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


class ToDoList extends StatelessWidget {

  ToDoList(this.user);

  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').document(user.uid).collection('todos').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            return ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return Row(
                  
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(document['task']),
                    ) ,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Checkbox(
                        value: document['completed'], 
                        onChanged: (bool value) {
                          document.reference.updateData({'completed':value});
                        },
                      ),
                    )
                    
                  ],
                  
                );
              }).toList(),
            );
        }
      },
    );
  }
}


class AddToDoPage extends StatelessWidget {

  AddToDoPage({this.user});

  final FirebaseUser user;
  final TextEditingController _textController = TextEditingController();


  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: Text("Add ToDo"),
      ),
      body: 
        Column(
          children: <Widget>[
            TextField(
            controller: _textController,
            onSubmitted: _addToDo,
            decoration: new InputDecoration.collapsed(
              hintText: "Create new task"),
          ),
            Center(
              child: IconButton(                                    
                icon: new Icon(Icons.send),      
                onPressed: () { 
                  _addToDo(_textController.text); 
                  Navigator.pop(context);
                },
              ),
            ),

          ],
        )
      
    );

  }

  _addToDo (String task) {
    Firestore.instance.collection('users').document(user.uid).collection('todos').document().setData({'task':task, 'completed':false});
    _textController.clear();
  }
  
}