class RoomModel {
  final int id;
  final String ownerEmail;
  final String shortName;
  final String title;
  final String description;
  final String acceptedEmails;

  RoomModel({
    required this.id,
    required this.ownerEmail,
    required this.shortName,
    required this.title,
    required this.description,
    required this.acceptedEmails,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
        id: json['id'],
        ownerEmail: json['owner_email'],
        shortName: json['short_name'],
        title: json['title'],
        description: json['description'],
        acceptedEmails: json['accepted_emails'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "owner_email": ownerEmail,
        "short_name": shortName,
        "title": title,
        "description": description,
        "accepted_emails": acceptedEmails,
      };
}
