import 'package:fly_todo/core/error_helper.dart';
import 'package:fly_todo/models/tokens.dart';
import 'package:fly_todo/repositories/datastore_repository.dart';
import 'package:http/http.dart' as http;

abstract class RequestHelper {
  static final DatastoreRepository _datastoreRepository = DatastoreRepository();

  static Future<String> get(String href, {bool doAuth = true}) async {
    final response = await http.get(
      Uri.parse(href),
      headers: await getHeaders(doAuth: doAuth, isJson: false),
    );

    return handleResponse(response, 200);
  }

  static Future<String> post(
    String href,
    String body, {
    bool doAuth = true,
    bool expectCreate = true,
  }) async {
    final response = await http.post(
      Uri.parse(href),
      headers: await getHeaders(doAuth: doAuth, isJson: true),
      body: body,
    );
    return handleResponse(response, expectCreate ? 201 : 200);
  }

  static Future<String> patch(String href, String body) async {
    final response = await http.patch(
      Uri.parse(href),
      headers: await getHeaders(isJson: true),
      body: body,
    );
    return handleResponse(response, 200);
  }

  static Future<String> delete(String href, String body) async {
    final response = await http.delete(
      Uri.parse(href),
      headers: await getHeaders(isJson: false),
      body: body,
    );
    return handleResponse(response, 204);
  }

  static String handleResponse(http.Response response, int expectedCode) {
    final success = response.statusCode == expectedCode;

    if (success) {
      return response.body;
    }

    throw Exception(ErrorHelper.getErrorMessage(response.body));
  }

  static Future<Map<String, String>> getHeaders({doAuth = true, isJson}) async {
    final Map<String, String> headers = {};

    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }

    if (doAuth) {
      Tokens tokens = await _datastoreRepository.getTokens();
      headers['Authorization'] = 'Bearer ${tokens.access}';
    }
    return headers;
  }
}
