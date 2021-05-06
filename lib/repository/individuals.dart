import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbz/repository/repo.dart';

import '../ontology/ontology.dart';

Future<String> addIndividualToClass(
    String classId, Individual individual) async {
  final propertyJson = jsonEncode(individual.toJson());
  final response = await http.post(
      Uri.http(defaultUrl, '/class/' + classId + "/individual"),
      body: propertyJson);
  if (response.statusCode == 200) {
    Map<String, dynamic> res = jsonDecode(response.body);
    return res["uid"];
  } else {
    throw Exception('Failed to create root class');
  }
}

Future<List<Individual>> fetchIndividuals(String name) async {
  Map<String, dynamic> queryParams = {
    "name": name,
  };
  final response =
      await http.get(Uri.http(defaultUrl, '/individuals', queryParams));
  if (response.statusCode == 200) {
    return parseIndividuals(response.body);
  } else {
    throw Exception('Failed to load classes');
  }
}

Future<Individual> fetchIndividual(String id) async {
  Map<String, dynamic> queryParams = {
    "id": id,
  };
  final response =
  await http.get(Uri.http(defaultUrl, '/individuals', queryParams));
  if (response.statusCode == 200) {
    return parseIndividuals(response.body).first;
  } else {
    throw Exception('Failed to load classes');
  }
}

