import 'dart:convert';

class OntologyClass {
  String id;
  final String name;
  bool isRoot;
  bool isSubRoot;
  bool isSoftDeleted;

  List<Property> properties;
  List<Relationship> relationships;
  List<OntologyClass> children;
  OntologyClass parent;

  OntologyClass(this.name) : isRoot = false;

  OntologyClass.withRoot(this.name, this.isRoot) : isSubRoot = false;

  OntologyClass.withSubRoot(this.name, this.isSubRoot) : isRoot = false;

  Map<String, dynamic> toJson() => {
        "uid": id != null ? id : "",
        'name': name,
        'isRoot': isSubRoot,
      };

  factory OntologyClass.fromJson(Map<String, dynamic> json) {
    var ontologyClass = OntologyClass(json['name']);
    ontologyClass.id = json['uid'];
    ontologyClass.isSubRoot = json['isRoot'];
    ontologyClass.children = [];
    ontologyClass.isSoftDeleted = json['isSoftDeleted'];
    if (json['subclasses'] != null) {
      for (var s in json['subclasses']) {
        var c = OntologyClass.fromJson(s);
        ontologyClass.children.add(c);
      }
    }
    return ontologyClass;
  }
}

List<OntologyClass> parseOntologyClasses(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<OntologyClass>((json) => OntologyClass.fromJson(json))
      .toList();
}

class Individual {
  String name;
  String classID;
  List<Property> properties;
  List<Relationship> relationships;

  Individual(this.name, this.classID);
}

class Property {
  String name;
  String type;
  String value; // ANY
}

class Relationship {
  String fromClassID;
  String toClassID;
  String relation;
}
