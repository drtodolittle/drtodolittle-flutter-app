// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToDoPage extends StatelessWidget {
  ToDoPage(this.user);

  final FirebaseUser user;

  static const String routeName = '/todo';
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr ToDo Little'),
      ),
      body: Column(
        children: <Widget>[_createToDoComposer(),],) 
    );
  }


  Widget _createToDoComposer() {
    return Container(
      margin: new EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: <Widget>[
          TextField(
            controller: _textController,
            onSubmitted: _addToDo,
            decoration: new InputDecoration.collapsed(
              hintText: "Create new task"),
          ),
          Container(                                                 
          margin: new EdgeInsets.symmetric(horizontal: 4.0),          
          child: new IconButton(                                      
            icon: new Icon(Icons.send),      
            onPressed: () => _addToDo(_textController.text)), 
        ),       
        ],
      ),
    );
  }

  _addToDo(String task) {
    Firestore.instance.collection('users').document(user.uid).collection('todos').document().setData({'task':task, 'completed':false});
    _textController.clear();
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
                return new ListTile(
                  title: new Text(document['task']),
                  subtitle: new Text(document['completed'].toString()),
                );
              }).toList(),
            );
        }
      },
    );
  }
}