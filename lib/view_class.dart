import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:pbz/ontology/ontology.dart';
import 'package:pbz/repository/class.dart';
import 'package:pbz/repository/individuals.dart';
import 'package:pbz/repository/property_type.dart';
import 'package:pbz/repository/repo.dart';

import 'individual.dart';

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
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  // insertNode(context, this.nodes);
                }
              },
              child: Text('Submit'),
            ),
          ), // value
        ],
      ),
    );
  }
}

class ViewClassState extends StatefulWidget {
  final String classId;

  ViewClassState({Key key, this.classId}) : super(key: key);

  @override
  ViewClassWidget createState() {
    return ViewClassWidget(this.classId);
  }
}

class ViewClassWidget extends State<ViewClassState> {
  final String classId;
  Future<OntologyClass> ontologyClass;

  Future navigateToEditIndividual(context, individual, ontologyClass) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditIndividualsState(
                  propertyTypes: ontologyClass.properties,
                  individualId: individual.id,
                )));
  }

  @override
  void initState() {
    super.initState();
    ontologyClass = getClass(classId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ontology'),
      ),
      body: FutureBuilder<OntologyClass>(
          future: ontologyClass,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [
                  Center(
                    child: Text(
                      "${snapshot.data.name}",
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  Text("Properties"),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data.properties == null
                        ? 0
                        : snapshot.data.properties.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext buildContext) {
                                    return AlertDialog(
                                      content: EditPropertyState(
                                        snapshot.data.id,
                                        key: UniqueKey(),
                                        propertyId:
                                            snapshot.data.properties[index].id,
                                        initialName: snapshot
                                            .data.properties[index].name,
                                        initialType: snapshot
                                            .data.properties[index].type,
                                        onSubmit: (property) {
                                          snapshot.data.properties[index] =
                                              property;
                                          setState(() {});
                                        },
                                      ),
                                    );
                                  });
                            },
                            trailing: IconButton(
                              icon: Icon(Icons.delete_forever),
                              onPressed: () {
                                setState(() {
                                  snapshot.data.properties.removeAt(index);
                                });
                              },
                            ),
                            title: Text(
                              snapshot.data.properties[index].name,
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle:
                                Text(snapshot.data.properties[index].type),
                          ),
                        ),
                      );
                    },
                  ),
                  CreatePropertyState(
                    snapshot.data.id,
                    key: UniqueKey(),
                    onSubmit: (property) {
                      if (snapshot.data.properties == null) {
                        snapshot.data.properties = [];
                      }
                      snapshot.data.properties.add(property);
                      setState(() {});
                    },
                  ),
                  Text("Individuals"),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data.individuals == null
                        ? 0
                        : snapshot.data.individuals.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            trailing: Icon(Icons.keyboard_arrow_right),
                            title: Text(
                              snapshot.data.individuals[index].name,
                              style: TextStyle(fontSize: 16),
                            ),
                            onTap: () {
                              navigateToEditIndividual(
                                  context,
                                  snapshot.data.individuals[index],
                                  snapshot.data);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  CreateIndividualState(
                    onSubmit: (value) {
                      if (snapshot.data.individuals == null) {
                        snapshot.data.individuals = [];
                      }
                      snapshot.data.individuals.add(value);
                      setState(() {});
                    },
                    classId: snapshot.data.id,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      child: Text("Go home"))
                ],
              );
            }
            return CircularProgressIndicator();
          }),
    );
  }

  ViewClassWidget(this.classId);
}

class CreatePropertyState extends StatefulWidget {
  final Function(PropertyType) onSubmit;
  final String classId;

  const CreatePropertyState(this.classId, {Key key, this.onSubmit})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CreatePropertyWidget(onSubmit, classId);
  }
}

class _CreatePropertyWidget extends State<CreatePropertyState> {
  String dropdownType;
  String propertyName;
  final String classId;
  final Function(PropertyType) onSubmit;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    dropdownType = 'String';
  }

  _CreatePropertyWidget(this.onSubmit, this.classId);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter property name',
              ),
              onChanged: (value) {
                propertyName = value;
              },
            ),
          ),
          Expanded(
            child: Center(
              child: DropdownButton<String>(
                value: dropdownType,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownType = newValue;
                  });
                },
                items: <String>['String', 'Boolean', 'Numeric']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      TextButton(
          onPressed: () async {
            var newProperty = PropertyType(propertyName, dropdownType);
            var id = await addPropertyType(classId, newProperty);
            newProperty.id = id;
            onSubmit(newProperty);
          },
          child: Text("add property")),
    ]);
  }
}

class EditPropertyState extends StatefulWidget {
  final Function(PropertyType) onSubmit;
  final String initialName;
  final String initialType;
  final String classId;
  final String propertyId;

  const EditPropertyState(this.classId,
      {Key key,
      this.onSubmit,
      this.initialName,
      this.initialType,
      this.propertyId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditPropertyWidget(
      onSubmit,
      classId,
      dropdownType: this.initialType,
      propertyId: this.propertyId,
      propertyName: this.initialName,
    );
  }
}

class _EditPropertyWidget extends State<EditPropertyState> {
  String dropdownType;

  String propertyName;
  String propertyId;
  final String classId;
  final Function(PropertyType) onSubmit;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    dropdownType = dropdownType;
    _controller = new TextEditingController(text: propertyName);
  }

  _EditPropertyWidget(this.onSubmit, this.classId,
      {this.dropdownType, this.propertyName, this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          children: [
            Flexible(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter property name',
                ),
                onChanged: (value) {
                  propertyName = value;
                },
              ),
            ),
            Flexible(
              child: Center(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: dropdownType,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownType = newValue;
                    });
                  },
                  items: <String>['String', 'Boolean', 'Numeric']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        TextButton(
            onPressed: () async {
              var newProperty =
                  PropertyType(propertyName, dropdownType, id: propertyId);
              editPropertyType(newProperty);
              onSubmit(newProperty);
            },
            child: Text("edit")),
      ]),
    );
  }
}

class CreateIndividualState extends StatefulWidget {
  final Function(Individual value) onSubmit;
  final String classId;

  const CreateIndividualState({Key key, this.onSubmit, this.classId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CreateIndividualWidget(onSubmit, classId);
  }
}

class _CreateIndividualWidget extends State<CreateIndividualState> {
  String name;
  final String classId;

  Function(Individual value) onSubmit;

  _CreateIndividualWidget(this.onSubmit, this.classId);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Enter individual name',
          ),
          onChanged: (value) {
            name = value;
          },
        ),
        TextButton(
            onPressed: () async {
              var individual = Individual(name, classID: classId);
              var id = await addIndividualToClass(classId, individual);
              individual.id = id;
              onSubmit(individual);
            },
            child: Text("add individual")),
      ],
    );
  }
}

class EditIndividualState extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditIndividualWidget();
  }
}

class _EditIndividualWidget extends State<EditIndividualState> {
  Individual individual;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(),
        ListView.builder(itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                trailing: Icon(Icons.keyboard_arrow_right),
                title: Text(
                  individual.properties[index].type.name,
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {},
              ),
            ),
          );
        }), // properties
        TextButton(onPressed: () {}, child: Text("add property")),
        ListView.builder(itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                trailing: Icon(Icons.keyboard_arrow_right),
                title: Text(
                  individual.relationships[index].name.name,
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {},
              ),
            ),
          );
        }), // // relationships
        TextButton(onPressed: () {}, child: Text("add relationship")),
      ],
    );
  }
}
