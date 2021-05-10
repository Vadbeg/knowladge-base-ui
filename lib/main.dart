import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:pbz/relationships.dart';
import 'package:pbz/repository/repo.dart';
import 'package:pbz/search.dart';
import 'package:pbz/view_class.dart';

import 'actions_dialogg.dart';
import 'add_class.dart';
import 'home_page.dart';
import 'ontology/ontology.dart';

import 'dart:async';

void main() => runApp(MainApplication());

class MainApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
        selectedRowColor: Colors.cyan[600],

        fontFamily: 'Georgia',

        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
    );
  }
}
