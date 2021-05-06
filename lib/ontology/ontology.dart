import 'dart:convert';

class OntologyClass {
  String id;
  final String name;
  bool isRoot;
  bool isSubRoot;
  bool isSoftDeleted;

  List<PropertyType> properties;
  List<Individual> individuals;
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
    if (json['propertyTypes'] != null) {
      ontologyClass.properties = [];
      for (var t in json['propertyTypes']) {
        var pt = PropertyType.fromJson(t);
        ontologyClass.properties.add(pt);
      }
    }
    if (json['individuals'] != null) {
      ontologyClass.individuals = [];
      for (var i in json['individuals']) {
        var individual = Individual.fromJson(i);
        ontologyClass.individuals.add(individual);
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

List<RelationshipName> parseRelationshipNames(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<RelationshipName>((json) => RelationshipName.fromJson(json))
      .toList();
}

List<Individual> parseIndividuals(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Individual>((json) => Individual.fromJson(json)).toList();
}

List<PropertyType> parseProperties(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<PropertyType>((json) => PropertyType.fromJson(json))
      .toList();
}

class Individual {
  String name;
  String classID;
  String id;
  List<PropertyValue> properties;
  List<Relationship> relationships;

  Map<String, dynamic> toJson() => {
        "uid": id,
        'name': name,
      };

  factory Individual.fromJson(Map<String, dynamic> json) {
    var i = Individual(json['name'], id: json['uid']);
    i.properties = [];
    if (json['propertyValues'] != null) {
      for (var v in json['propertyValues']) {
        i.properties.add(PropertyValue.fromJson(v));
      }
    }
    i.relationships = [];
    if (json['relationshipTriples'] != null) {
      for (var t in json['relationshipTriples']) {
        i.relationships.add(Relationship.fromJson(t));
      }
    }
    return i;
  }

  Individual(this.name, {this.classID, this.id});
}

List<Individual> parse(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Individual>((json) => Individual.fromJson(json)).toList();
}

class PropertyValue {
  PropertyType type;
  String value;
  String id;

  Map<String, dynamic> toJson() => {
        "uid": id,
        'value': value,
        'propertyType': type.toJson(),
      };

  factory PropertyValue.fromJson(Map<String, dynamic> json) {
    var v = PropertyValue(json['value'], id: json['uid']);
    if (json['propertyTypeRef'] != null) {
      for (var t in json['propertyTypeRef']) {
        v.type = PropertyType.fromJson(t);
      }
    }

    return v;
  }

  PropertyValue(this.value, {this.id, this.type}); // ANY
}

class PropertyType {
  String id;
  String name;
  String type;

  PropertyType(this.name, this.type, {this.id});

  Map<String, dynamic> toJson() => {
        "uid": id,
        'name': name,
        'propertyType': type,
      };

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(json['name'], json['propertyType'], id: json['uid']);
  }
}

class RelationshipName {
  String id;
  String name;

  RelationshipName(this.name, {this.id});

  Map<String, dynamic> toJson() => {
        "uid": id,
        'name': name,
      };

  factory RelationshipName.fromJson(Map<String, dynamic> json) {
    return RelationshipName(json['name'], id: json['uid']);
  }
}

class Relationship {
  Individual fromIndividual;

  Relationship(this.fromIndividual, this.toIndividual, this.name, {this.id});

  Individual toIndividual;
  RelationshipName name;
  String id;

  Map<String, dynamic> toJson() => {
        "uid": id,
        'subject': fromIndividual.toJson(),
        'object': toIndividual.toJson(),
        'relationshipName': name.toJson(),
      };

  factory Relationship.fromJson(Map<String, dynamic> json) {
    var r = Relationship(
      Individual.fromJson(json['subject']),
      Individual.fromJson(json['object']),
      RelationshipName.fromJson(json['relationshipName']),
    );
    r.id = json['uid'];
    return r;
  }
}
