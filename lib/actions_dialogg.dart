import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:pbz/repository/class.dart';
import 'package:pbz/view_class.dart';

import 'add_class.dart';
import 'ontology/ontology.dart';

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
                ViewClassState(key: UniqueKey(), classId: node.data.id)));
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
