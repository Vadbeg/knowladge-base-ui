import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbz/repository/repo.dart';

import '../ontology/ontology.dart';

Future<String> addPropertyType(String classId, PropertyType property) async {
  final propertyJson = jsonEncode(property.toJson());
  final response = await http.post(
      Uri.http(defaultUrl, '/class/' + classId + "/property"),
      body: propertyJson);
  if (response.statusCode == 200) {
    Map<String, dynamic> res = jsonDecode(response.body);
    return res["uid"];
  } else {
    throw Exception('Failed to create root class');
  }
}

void editPropertyType(PropertyType property) async {
  final propertyJson = jsonEncode(property.toJson());
  final response = await http.patch(
      Uri.http(defaultUrl, "/property/" + property.id),
      body: propertyJson);
  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception('Failed to create root class');
  }
}
