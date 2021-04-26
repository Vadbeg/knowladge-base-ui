import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:pbz/ontology.dart';

class EditIndividualsState extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class EditIndividualsWidget extends State<EditIndividualsState> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class EditClassPropertiesState extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EditClassPropertiesWidget();
  }
}

class EditClassPropertiesWidget extends State<EditClassPropertiesState> {
  String name;
  String type;
  String value;

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property'),
      ),
      body: Column(
        children: [
          TextFormField(
            onSaved: (String value) {
              name = value;
            },
          ), // name
          TextFormField(
            onSaved: (String value) {
              type = value;
            },
          ), // type
          TextFormField(
            onSaved: (String value) {
              this.value = value;
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
                  // insertNode(context, this.nodes);
                }
              },
              child: Text('Submit'),
            ),
          ),// value
        ],
      ),
    );
  }
}

class ViewClassState extends StatefulWidget {
  final Node node;

  ViewClassState({Key key, this.node}) : super(key: key);

  @override
  ViewClassWidget createState() {
    return ViewClassWidget(this.node);
  }
}

class ViewClassWidget extends State<ViewClassState> {
  final Node node;
  OntologyClass ontologyClass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ontology'),
      ),
      body: ListView(
        children: [
          Text("Class name ${node.data.name}"),
          Text("Individuals"),
          TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("Edit individuals")),
          TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("Edit properties")),
          TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("Go home"))
        ],
      ),
    );
  }

  ViewClassWidget(this.node);
}
