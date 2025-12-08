class UserModel {
  final String email;
  final String name;
  final String surname;
  final String role;
  final String visitReason;
  final int visible;
  UserModel({
    required this.email,
    required this.name,
    required this.surname,
    required this.role,
    required this.visitReason,
    required this.visible,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    email: json['email'],
    name: json['name'],
    surname: json['surname'],
    role: json['role'],
    visitReason: json['visit_reason'],
    visible: json['visible'],
  );
}
