class UserModel {
  final String email;
  UserModel({required this.email});
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(email: json['email']);
}
