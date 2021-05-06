import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbz/repository/repo.dart';

import '../ontology/ontology.dart';

Future<String> addPropertyValue(
    String individualId, PropertyValue property) async {
  final propertyJson = jsonEncode(property.toJson());
  final response = await http.post(
      Uri.http(defaultUrl, '/individual/' + individualId + "/property"),
      body: propertyJson);
  if (response.statusCode == 200) {
    Map<String, dynamic> res = jsonDecode(response.body);
    return res["uid"];
  } else {
    throw Exception('Failed to create root class');
  }
}

