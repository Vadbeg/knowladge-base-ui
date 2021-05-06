import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbz/repository/relationships.dart';

import 'ontology/ontology.dart';

class RelationshipWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RelationshipState();
  }
}

class _RelationshipState extends State<RelationshipWidget> {
  Future<List<RelationshipName>> relationshipsNames;
  String name;

  @override
  void initState() {
    super.initState();
    relationshipsNames = fetchRelationshipNames("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Relationships'),
        ),
        body: FutureBuilder<List<RelationshipName>>(
          future: relationshipsNames,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      name = value;
                    },
                  ),
                  TextButton(
                      onPressed: () async {
                        var relName = RelationshipName(name);
                        var relId = await createRelationshipName(relName);
                        relName.id = relId;
                        snapshot.data.add(RelationshipName(
                          name,
                          id: "id",
                        ));
                        setState(() {});
                      },
                      child: Text("add")),
                  ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListItem(
                                id: snapshot.data[index].id,
                                name: snapshot.data[index].name,
                                onDelete: () {
                                  snapshot.data.removeAt(index);
                                  setState(() {});
                                },
                                onEdit: (value) {
                                  editRelationshipName(RelationshipName(value,
                                      id: snapshot.data[index].id));
                                  snapshot.data[index].name = value;
                                  setState(() {});
                                },
                              )),
                        );
                      })
                ],
              );
            }
            return CircularProgressIndicator();
          },
        ));
  }
}

class ListItem extends StatefulWidget {
  final String name;
  final String id;
  final Function(String) onEdit;
  final Function() onDelete;

  const ListItem({Key key, this.name, this.id, this.onEdit, this.onDelete})
      : super(key: key);

  @override
  _ListItemState createState() => _ListItemState(id, name, onEdit, onDelete);
}

class _ListItemState extends State<ListItem> {
  bool _isEnabled = false;
  String name;
  final String id;
  final Function(String) onEdit;
  final Function() onDelete;

  _ListItemState(this.id, this.name, this.onEdit, this.onDelete);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
        initialValue: name,
        enabled: _isEnabled,
        decoration: InputDecoration(
          hintText: 'Enter a text',
        ),
        onChanged: (value) {
          name = value;
        },
      ),
      // The icon button which will notify list item to change
      trailing: Wrap(children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            setState(() {
              _isEnabled = !_isEnabled;
            });
            if (!_isEnabled) {
              onEdit(name);
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.delete_forever),
          onPressed: () {
            onDelete();
          },
        ),
      ]),
    );
  }
}
