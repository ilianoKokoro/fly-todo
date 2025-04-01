import "dart:convert";

import "package:fly_todo/core/constants.dart";
import "package:fly_todo/core/request_helper.dart";
import "package:fly_todo/models/tokens.dart";
import "package:fly_todo/repositories/datastore_repository.dart";

class AuthRepository {
  final DatastoreRepository _datastoreRepository = DatastoreRepository();

  Future<String> logIn(String username, String password) async {
    final body = {"name": username, "password": password};
    return await RequestHelper.post(
      Urls.login,
      jsonEncode(body),
      doAuth: false,
      expectCreate: false,
    );
  }

  Future<String> signUp(String username, String email, String password) async {
    final body = {"name": username, "email": email, "password": password};
    return await RequestHelper.post(
      Urls.signup,
      jsonEncode(body),
      doAuth: false,
    );
  }

  void logOut() async {
    Tokens tokens = await _datastoreRepository.getTokens();
    final body = jsonEncode({"refreshToken": tokens.refresh});
    await RequestHelper.delete(Urls.logout, body);
  }

  void refreshAccessToken() async {
    Tokens tokens = await _datastoreRepository.getTokens();
    final body = jsonEncode({"refreshToken": tokens.refresh});
    final responseBody = await RequestHelper.post(Urls.refresh, body);
    _datastoreRepository.saveTokens(
      Tokens.fromJson(jsonDecode(responseBody)["tokens"]),
    );
  }
}
