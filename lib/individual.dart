import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbz/ontology/ontology.dart';
import 'package:pbz/repository/class.dart';
import 'package:pbz/repository/individuals.dart';
import 'package:pbz/repository/property_value.dart';
import 'package:pbz/repository/relationships.dart';

class EditIndividualsState extends StatefulWidget {
  final List<PropertyType> propertyTypes;
  final String individualId;

  const EditIndividualsState({Key key, this.propertyTypes, this.individualId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditIndividualsWidget(propertyTypes, individualId);
  }
}

class _EditIndividualsWidget extends State<EditIndividualsState> {
  PropertyType dropdownType;
  List<PropertyType> propertyTypes;
  String propertyValue;
  final String individualId;
  Future<Individual> individual;
  RelationshipName selectedRelationshipName;
  Individual selectedIndividual;

  _EditIndividualsWidget(this.propertyTypes, this.individualId);

  @override
  void initState() {
    super.initState();
    individual = fetchIndividual(individualId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Individual'),
        ),
        body: FutureBuilder<Individual>(
          future: individual,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(children: [
                TextFormField(
                  initialValue: snapshot.data.name,
                ),
                Text("Properties"),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.properties == null
                      ? 0
                      : snapshot.data.properties.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      trailing: IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () {
                          setState(() {
                            snapshot.data.properties.removeAt(index);
                          });
                        },
                      ),
                      title: Text(snapshot.data.properties[index].value),
                      subtitle: Text(snapshot.data.properties[index].type.name +
                          ", " +
                          snapshot.data.properties[index].type.type),
                    );
                  },
                ),
                DropdownButton<PropertyType>(
                  value: dropdownType,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (PropertyType newValue) {
                    setState(() {
                      dropdownType = newValue;
                    });
                  },
                  items: propertyTypes.map<DropdownMenuItem<PropertyType>>(
                      (PropertyType value) {
                    return DropdownMenuItem<PropertyType>(
                      value: value,
                      child: Text(value.name + ", " + value.type),
                    );
                  }).toList(),
                ),
                TextField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter property value',
                  ),
                  onChanged: (value) {
                    propertyValue = value;
                  },
                ),
                // value
                // properties
                TextButton(
                    onPressed: () async {
                      var property =
                          PropertyValue(propertyValue, type: dropdownType);
                      var id = await addPropertyValue(individualId, property);
                      property.id = id;
                      snapshot.data.properties.add(property);
                      setState(() {});
                    },
                    child: Text("add property")),
                Text("Relationships"),
                ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                ),
                DropdownSearch<RelationshipName>(
                  itemAsString: (name) {
                    return name.name;
                  },
                  label: "Relationship name",
                  isFilteredOnline: true,
                  showClearButton: true,
                  showSearchBox: true,
                  onFind: (String filter) async {
                    var response = await fetchRelationshipNames(
                      filter,
                    );
                    return response;
                  },
                  onChanged: (RelationshipName data) {
                    selectedRelationshipName = data;
                  },
                ),
                DropdownSearch<Individual>(
                  itemAsString: (name) {
                    return name.name;
                  },
                  label: "Individual name",
                  isFilteredOnline: true,
                  showClearButton: true,
                  showSearchBox: true,
                  onFind: (String filter) async {
                    var response = await fetchIndividuals(
                      filter,
                    );
                    return response;
                  },
                  onChanged: (Individual data) {
                    selectedIndividual = data;
                  },
                ),
                TextButton(
                    onPressed: () async {
                      var relationship = Relationship(snapshot.data,
                          selectedIndividual, selectedRelationshipName);
                      var relId = await addRelationshipToIndividual(
                          individualId, relationship);
                      relationship.id = relId;
                      snapshot.data.relationships.add(relationship);
                      setState(() {

                      });
                    },
                    child: Text("add relationship")),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.relationships == null
                      ? 0
                      : snapshot.data.relationships.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(snapshot.data.relationships[index].name.name),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () {
                          setState(() {
                            snapshot.data.relationships.removeAt(index);
                          });
                        },
                      ),
                      subtitle: Text(snapshot
                              .data.relationships[index].fromIndividual.name +
                          ", " +
                          snapshot.data.relationships[index].toIndividual.name),
                    );
                  },
                ),
              ]);
            }
            return CircularProgressIndicator();
          },
        ));
  }
}
