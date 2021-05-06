import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbz/repository/repo.dart';

import '../ontology/ontology.dart';

Future<List<OntologyClass>> fetchClasses() async {
  final response = await http.get(Uri.http('localhost:9999', '/classes'));
  if (response.statusCode == 200) {
    return parseOntologyClasses(response.body);
  } else {
    throw Exception('Failed to load classes');
  }
}

void deleteClass(String id) async {
  final response = await http.delete(Uri.http(defaultUrl, '/class/' + id));
  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception('Failed to delete class');
  }
}

Future<String> createRootClass(OntologyClass ontologyClass) async {
  final requestBody = jsonEncode(ontologyClass.toJson());
  var req = "{\"parent\":$requestBody}";
  print(requestBody);
  final response = await http.post(Uri.http(defaultUrl, '/class'), body: req);
  if (response.statusCode == 200) {
    Map<String, dynamic> res = jsonDecode(response.body);
    return res["uid"];
  } else {
    throw Exception('Failed to create root class');
  }
}

Future<String> createSubClass(
    OntologyClass parentClass, OntologyClass child) async {
  final parentClassJson = jsonEncode(parentClass.toJson());
  final childClassJson = jsonEncode(child.toJson());
  final req = "{\"parent\":$parentClassJson,\"subclass\":$childClassJson}";
  final response = await http.post(Uri.http(defaultUrl, '/class'), body: req);
  if (response.statusCode == 200) {
    Map<String, dynamic> res = jsonDecode(response.body);
    return res["uid"];
  } else {
    throw Exception('Failed to create root class');
  }
}

Future<OntologyClass> getClass(String id) async {
  final response = await http.get(Uri.http(defaultUrl, '/class/' + id));
  if (response.statusCode == 200) {
    Map<String, dynamic> res = jsonDecode(response.body);
    return OntologyClass.fromJson(res);
  } else {
    throw Exception('Failed to get class');
  }
}
