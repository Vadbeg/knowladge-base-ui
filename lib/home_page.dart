


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:pbz/relationships.dart';
import 'package:pbz/repository/class.dart';
import 'package:pbz/repository/repo.dart';
import 'package:pbz/search.dart';

import 'actions_dialogg.dart';
import 'ontology/ontology.dart';

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

  Widget currentWidget;

  _HomePageState()
      : root = Node<OntologyClass>(
      label: 'Root',
      key: 'root',
      children: <Node<OntologyClass>>[],
      data: OntologyClass.withRoot("Root", true));

  @override
  void initState() {
    super.initState();
    currentWidget = buildTreeView();
    futureClasses = fetchClasses();
  }

  Widget buildTreeView() {
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

    return FutureBuilder<List<OntologyClass>>(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Ontology'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: 'Tree',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Relations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              currentWidget = buildTreeView();
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RelationshipWidget()));
              break;
            case 2:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchState()));
          }
        },
      ),
      body: Center(
        child: buildTreeView(),
      ),
    );
  }
}
