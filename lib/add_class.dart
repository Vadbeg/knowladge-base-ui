import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:pbz/repository/class.dart';
import 'package:pbz/repository/repo.dart';
import 'package:pbz/view_class.dart';
import 'package:uuid/uuid.dart';

import 'ontology/ontology.dart';

class AddClassState extends StatefulWidget {
  final List<Node> nodes;
  final Node node;

  AddClassState({Key key, this.nodes, this.node}) : super(key: key);

  @override
  _AddClassState createState() {
    return _AddClassState(nodes, node);
  }
}

class _AddClassState extends State<AddClassState> {
  List<Node<OntologyClass>> nodes;
  Node<OntologyClass> node;
  String name;
  Future<String> newNodeId;
  OntologyClass newOntologyClass;

  Future navigateToViewClass(context) async {
    Future.delayed(Duration.zero, () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ViewClassState(key: UniqueKey(), classId: node.data.id)));
    });
  }

  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  void insertNode(BuildContext context, List<Node> nodes) {
    for (var n in nodes) {
      if (n == node) {
        if (node.data.isRoot != null && node.data.isRoot) {
          var ontologyClass = OntologyClass.withSubRoot(name, true);
          newOntologyClass = ontologyClass;
          setState(() {
            newNodeId = createRootClass(ontologyClass);
          });
        } else {
          var childClass = OntologyClass.withRoot(name, false);
          newOntologyClass = childClass;
          setState(() {
            newNodeId = createSubClass(node.data, childClass);
          });
        }
        return;
      } else {
        insertNode(context, n.children);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ontology'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(content: Text('Processing Data')));
                      _formKey.currentState.save();
                      insertNode(context, this.nodes);
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
              FutureBuilder<String>(
                future: newNodeId,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    newOntologyClass.id = snapshot.data;
                    var ontologyNode = Node<OntologyClass>(
                        key: snapshot.data,
                        label: name,
                        data: newOntologyClass,
                        children: <Node<OntologyClass>>[]);
                    node.children.add(ontologyNode);
                    node = ontologyNode;
                    navigateToViewClass(context);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return LinearProgressIndicator();
                },
              ),
            ],
          ),
        ));
  }

  _AddClassState(this.nodes, this.node);
}
