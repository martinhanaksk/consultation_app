// block_model.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Represents a consultation block.

class BlockModel {
  // Primary key
  final int id;
  // Date of the block (YYYY-MM-DD
  final DateTime date;
  final int roomId;
  // 1 = online, 0 = in-person
  final int isOnline;

  BlockModel({
    required this.id,
    required this.date,
    required this.roomId,
    required this.isOnline,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) => BlockModel(
    id: json['id'],
    date: DateTime.parse(json['date']),
    roomId: json['room_id'],
    isOnline: json['is_online'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date.toIso8601String(),
    "room_id": roomId,
    "is_online": isOnline,
  };
}
