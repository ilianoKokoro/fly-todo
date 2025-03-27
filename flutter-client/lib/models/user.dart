class User {
  String name;
  String email;
  String href;

  User(this.name, this.email, this.href);

  User.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      email = json['email'] as String,
      href = json['href'] as String;

  Map<String, dynamic> toJson() => {'name': name, 'email': email, "href": href};
}
