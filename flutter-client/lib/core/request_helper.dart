import 'dart:convert';

import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/core/error_helper.dart';
import 'package:fly_todo/models/tokens.dart';
import 'package:fly_todo/models/user.dart';
import 'package:fly_todo/repositories/datastore_repository.dart';
import 'package:http/http.dart' as http;

abstract class RequestHelper {
  static final DatastoreRepository _datastoreRepository = DatastoreRepository();
  static bool _isRefreshing = false;

  static Future<String> get(String href, {bool doAuth = true}) async {
    return _makeRequest(
      () async => http.get(
        Uri.parse(href),
        headers: await getHeaders(doAuth: doAuth, isJson: false),
      ),
      200,
    );
  }

  static Future<String> post(
    String href,
    String body, {
    bool doAuth = true,
    bool expectCreate = true,
    bool addNameHeader = false,
  }) async {
    return _makeRequest(
      () async => http.post(
        Uri.parse(href),
        headers: await getHeaders(
          doAuth: doAuth,
          isJson: true,
          addNameHeader: addNameHeader,
        ),
        body: body,
      ),
      expectCreate ? 201 : 200,
    );
  }

  static Future<String> patch(String href, String body) async {
    return _makeRequest(
      () async => http.patch(
        Uri.parse(href),
        headers: await getHeaders(isJson: true),
        body: body,
      ),
      200,
    );
  }

  static Future<String> delete(String href, String body) async {
    return _makeRequest(
      () async => http.delete(
        Uri.parse(href),
        headers: await getHeaders(isJson: true),
        body: body,
      ),
      204,
    );
  }

  static Future<String> _makeRequest(
    Future<http.Response> Function() requestFn,
    int expectedCode, {
    int retryCount = 0,
  }) async {
    final response = await requestFn();

    if (response.statusCode == 401 && retryCount == 0) {
      final tokens = await _datastoreRepository.getTokens();
      if (tokens.refresh.isNotEmpty) {
        await _refreshTokens();
        return _makeRequest(
          requestFn,
          expectedCode,
          retryCount: retryCount + 1,
        );
      }
    }

    return handleResponse(response, expectedCode);
  }

  static Future<void> _refreshTokens() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      Tokens tokens = await _datastoreRepository.getTokens();
      final body = jsonEncode({"refreshToken": tokens.refresh});
      final responseBody = await post(Urls.refresh, body, addNameHeader: true);
      _datastoreRepository.saveTokens(
        Tokens.fromJson(jsonDecode(responseBody)["tokens"]),
      );
    } finally {
      _isRefreshing = false;
    }
  }

  static String handleResponse(http.Response response, int expectedCode) {
    final success = response.statusCode == expectedCode;

    if (success) {
      return response.body;
    }

    throw Exception(ErrorHelper.getErrorMessage(response.body));
  }

  static Future<Map<String, String>> getHeaders({
    bool doAuth = true,
    bool addNameHeader = false,
    bool isJson = false,
  }) async {
    final Map<String, String> headers = {};
    if (addNameHeader) {
      User user = await _datastoreRepository.getUser();
      headers['name'] = user.name;
    }

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
