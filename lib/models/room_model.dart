// room_model.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Represents a consultation room owned by a teacher/owner.
// including access control and cancellation policy.

class RoomModel {
  // Primary key
  final int id;
  // Owner of the room
  final String ownerEmail;
  // Used for storing links
  final String link;
  // Room title
  final String title;
  // Optional description
  final String description;
  // Comma-separated list of allowed emails or domains (@vutbr.cz, test@example.com)
  final String acceptedEmails;
  // Minimum hours before a block starts within which cancellation is still allowed
  final int cancellationNoticeHours;

  RoomModel({
    required this.id,
    required this.ownerEmail,
    required this.link,
    required this.title,
    required this.description,
    required this.acceptedEmails,
    required this.cancellationNoticeHours,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
    id: json['id'],
    ownerEmail: json['owner_email'],
    link: json['link'],
    title: json['title'],
    description: json['description'],
    acceptedEmails: json['accepted_emails'],
    cancellationNoticeHours: json['cancellation_notice_hours'],
  );
}
