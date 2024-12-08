class Usermodel {
  String id;
  String name;
  String email;

  Usermodel({this.id = "", required this.name, required this.email});

  Usermodel.fromJson(Map<String, dynamic> json)
      : this(
      id: json['id'],
      name: json['name'],
      email: json['email']
  );
  Map<String, dynamic> tojson() {
    return {
      "id": id,
      "name": name,
      "email": email,
    };
  }
}