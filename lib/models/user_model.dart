class UserModel {
  final String name;
  final String surname;
  final String email;
  final String visitReason;
  UserModel({
    required this.name,
    required this.surname,
    required this.email,
    required this.visitReason,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json['name'],
    surname: json['surname'],
    email: json['email'],
    visitReason: json['visit_reason'],
  );
}
