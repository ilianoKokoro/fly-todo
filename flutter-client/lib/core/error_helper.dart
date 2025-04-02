import 'dart:convert';

import 'package:fly_todo/core/extensions.dart';

class ErrorHelper {
  static String getErrorMessage(String jsonString) {
    final jsonObject = jsonDecode(jsonString);
    try {
      if (jsonObject.containsKey('errors')) {
        final errors = jsonObject['errors'];

        if (errors is List) {
          final firstError = errors.first;
          if (firstError is Map) {
            return firstError.values.first.toString();
          }
        } else if (errors is Map) {
          final firstError = errors.values.first;
          if (firstError is List) return firstError.first.toString();
          return firstError.toString();
        }
      }
      if (jsonObject.containsKey('userMessage')) {
        return jsonObject['userMessage'].toString();
      }

      if (jsonObject.containsKey('message')) {
        return jsonObject['message'].toString();
      }

      return "Unknown error";
      // return jsonString;
    } on Exception catch (ex) {
      return ex.getMessage;
    }
  }
}
