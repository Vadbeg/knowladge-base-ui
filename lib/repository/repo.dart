import 'dart:convert';

import 'package:http/http.dart' as http;

const defaultUrl =
    String.fromEnvironment('SERVER_URL', defaultValue: 'localhost:9999');

class SearchParameters {
  String name;
  String propertyValue;
  String propertyType;
  String propertyName;

  Map<String, dynamic> getMap() {
    return {
      "name": name,
      "propertyValue": propertyValue,
      "propertyType": propertyType,
      "propertyName": propertyName,
    };
  }

  SearchParameters(
      {this.name, this.propertyValue, this.propertyType, this.propertyName});
}

class SearchResponse {
  final String id;
  final String name;
  final String type;

  SearchResponse(this.id, this.name, this.type);

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(json['uid'], json['name'], json['dgraph.type'][0]);
  }
}

List<SearchResponse> parseSearchResponse(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<SearchResponse>((json) => SearchResponse.fromJson(json))
      .toList();
}

Future<List<SearchResponse>> search(SearchParameters parameters) async {
  final response =
      await http.get(Uri.http(defaultUrl, '/search', parameters.getMap()));
  if (response.statusCode == 200) {
    return parseSearchResponse(response.body);
  } else {
    throw Exception('Failed to load classes');
  }
}
