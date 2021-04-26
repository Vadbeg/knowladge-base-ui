import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:pbz/repo.dart';
import 'package:pbz/view_class.dart';

import 'add_class.dart';
import 'ontology.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MainApplication());

class MainApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;
  final List<Node<OntologyClass>> nodes;
  final Node<OntologyClass> node;
  final Function refreshFunc;

  Future navigateToAddClass(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AddClassState(key: UniqueKey(), nodes: nodes, node: node)));
  }

  Future navigateToViewClass(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ViewClassState(key: UniqueKey(), node: node)));
  }

  void deleteNodeWithNodes(Node removedNode, Node parent, List<Node> nodes) {
    for (var n in nodes) {
      if (n == removedNode) {
        if (parent == null) {
          nodes.remove(n);
          refreshFunc();
        } else {
          parent.children.remove(removedNode);
          refreshFunc();
        }
        return;
      } else {
        deleteNodeWithNodes(removedNode, n, n.children);
      }
    }
  }

  MyAlertDialog({
    this.title,
    this.content,
    this.actions = const [],
    this.nodes,
    this.node,
    this.refreshFunc,
  });

  final snackBar = SnackBar(content: Text("Can't do it with parent"));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        this.title,
      ),
      actions: this.actions,
      content: Row(children: [
        TextButton(
            onPressed: () {
              navigateToAddClass(context);
            },
            child: Text("add subclass")),
        TextButton(
            onPressed: () {
              if (node.key == "root" ||
                  (node.children != null && node.children.length > 0)) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }
              deleteClass(node.key);
              deleteNodeWithNodes(node, null, nodes);
              refreshFunc();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
            child: Text("remove(only leaf)")),
        TextButton(
            onPressed: () {
              if (node.key == "root") {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }
              navigateToViewClass(context);
            },
            child: Text("view/edit")),
      ]),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

void convertToNodes(
    List<OntologyClass> classes, List<Node<OntologyClass>> nodes) {
  if (classes == null) {
    return;
  }
  for (var c in classes) {
    if (c.isSoftDeleted) {
      continue;
    }
    var ontologyClass = OntologyClass(c.name);
    ontologyClass.id = c.id;
    ontologyClass.isSubRoot = c.isSubRoot;
    var node = Node<OntologyClass>(
        key: c.id,
        label: c.name,
        children: <Node<OntologyClass>>[],
        data: ontologyClass);
    nodes.add(node);
    convertToNodes(c.children, node.children);
  }
}

class _HomePageState extends State<HomePage> {
  List<Node<OntologyClass>> nodes;
  final Node<OntologyClass> root;
  Future<List<OntologyClass>> futureClasses;

  _HomePageState()
      : root = Node<OntologyClass>(
            label: 'Root',
            key: 'root',
            children: <Node<OntologyClass>>[],
            data: OntologyClass.withRoot("Root", true));

  @override
  void initState() {
    super.initState();
    futureClasses = fetchClasses();
  }

  @override
  Widget build(BuildContext context) {
    List<Node<OntologyClass>> nodes = [
      root,
    ];
    TreeViewController _treeViewController =
        TreeViewController(children: nodes);
    this.nodes = nodes;
    void refresh() {
      setState(() {
        this.nodes = this.nodes;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Ontology'),
      ),
      body: Center(
          child: FutureBuilder<List<OntologyClass>>(
        future: futureClasses,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            root.children.clear();
            convertToNodes(snapshot.data, root.children);
            return TreeView(
              controller: _treeViewController,
              supportParentDoubleTap: true,
              onNodeTap: (key) {},
              onNodeDoubleTap: (key) {
                Node selectedNode = _treeViewController.getNode(key);
                showDialog(
                    context: context,
                    builder: (BuildContext buildContext) {
                      return MyAlertDialog(
                        title: 'Actions',
                        content: 'Dialog content',
                        nodes: nodes,
                        node: selectedNode,
                        refreshFunc: () {
                          refresh();
                        },
                      );
                    });
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      )),
    );
  }
}
