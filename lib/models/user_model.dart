// user_model.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Represents the authenticated user's profile.

class UserModel {
  // Primary key
  final String email;
  final String name;
  final String surname;
  // 'teacher' or 'student'
  final String role;
  // Purpose of the visit (e.g., 'DP', 'teacher')
  final String visitReason;
  // 1 = visible, 0 = hidden
  final int visible;
  // sets how many hours before consultation user will get notification (multiple)
  final List<int> notificationHours;
  UserModel({
    required this.email,
    required this.name,
    required this.surname,
    required this.role,
    required this.visitReason,
    required this.visible,
    required this.notificationHours,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    email: json['email'],
    name: json['name'],
    surname: json['surname'],
    role: json['role'],
    visitReason: json['visit_reason'],
    visible: json['visible'],
    notificationHours: json['notification_times'],
  );
}
