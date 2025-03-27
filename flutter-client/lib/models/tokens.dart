class Tokens {
  String access;
  String refresh;

  Tokens(this.access, this.refresh);

  Tokens.fromJson(Map<String, dynamic> json)
    : access = json['accessToken'] as String,
      refresh = json['refreshToken'] as String;

  Map<String, dynamic> toJson() => {
    'accessToken': access,
    'refreshToken': refresh,
  };
}
