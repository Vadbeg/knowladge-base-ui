import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbz/repository/repo.dart';
import 'package:pbz/view_class.dart';

class SearchState extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchWidget();
  }
}

class SearchWidget extends State<SearchState> {
  String searchName;
  String propertyValue;
  String propertyName;
  String propertyType;
  Future<List<SearchResponse>> searchResponse;

  Future navigateToViewClass(context, String classId) async {
    Future.delayed(Duration.zero, () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ViewClassState(key: UniqueKey(), classId: classId)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          TextFormField(
            onChanged: (value) {
              searchName = value;
            },
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter name of class or individual',
            ),
          ),
          TextFormField(
            onChanged: (value) {
              propertyName = value;
            },
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter property name',
            ),
          ),
          TextFormField(
            onChanged: (value) {
              propertyType = value;
            },
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter property type',
            ),
          ),
          TextFormField(
            onChanged: (value) {
              propertyValue = value;
            },
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter property value',
            ),
          ),
          TextButton(
              onPressed: () {
                searchResponse = search(SearchParameters(
                  name: searchName,
                  propertyType: propertyType,
                  propertyName: propertyName,
                  propertyValue: propertyValue,
                ));
                setState(() {});
              },
              child: Text("Search")),
          FutureBuilder(
              future: searchResponse,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              if (snapshot.data[index].type == "class") {
                                navigateToViewClass(
                                    context, snapshot.data[index].id);
                              }
                            },
                            title: Text(
                              snapshot.data[index].name,
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(snapshot.data[index].type),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return LinearProgressIndicator();
                }
              })
        ],
      ),
    );
  }
}
