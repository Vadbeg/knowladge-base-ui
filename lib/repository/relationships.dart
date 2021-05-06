import 'dart:convert';

import 'package:pbz/repository/repo.dart';
import 'package:http/http.dart' as http;

import '../ontology/ontology.dart';

Future<String> createRelationshipName(RelationshipName name) async {
  final requestBody = jsonEncode(name.toJson());
  final response =
      await http.post(Uri.http(defaultUrl, '/relationship'), body: requestBody);
  if (response.statusCode == 200) {
    Map<String, dynamic> res = jsonDecode(response.body);
    return res["uid"];
  } else {
    throw Exception('Failed to create root class');
  }
}

Future<String> addRelationshipToIndividual(
    String individualID, Relationship relationship) async {
  final requestBody = jsonEncode(relationship.toJson());
  final response = await http.post(
      Uri.http(defaultUrl, '/individual/' + individualID + "/relationship"),
      body: requestBody);
  if (response.statusCode == 200) {
    Map<String, dynamic> res = jsonDecode(response.body);
    return res["uid"];
  } else {
    throw Exception('Failed to create root class');
  }
}

void editRelationshipName(RelationshipName name) async {
  final requestBody = jsonEncode(name.toJson());
  final response = await http.patch(
      Uri.http(defaultUrl, '/relationship/' + name.id),
      body: requestBody);
  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception('Failed to create root class');
  }
}

Future<List<RelationshipName>> fetchRelationshipNames(String name) async {
  Map<String, dynamic> queryParams = {
    "name": name,
  };
  final response =
      await http.get(Uri.http(defaultUrl, '/relationships', queryParams));
  if (response.statusCode == 200) {
    return parseRelationshipNames(response.body);
  } else {
    throw Exception('Failed to load classes');
  }
}
