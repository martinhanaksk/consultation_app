class BlockModel {
  final int id;
  final DateTime date;
  final int roomId;

  BlockModel({required this.id, required this.date, required this.roomId});

  factory BlockModel.fromJson(Map<String, dynamic> json) => BlockModel(
    id: json['id'],
    date: DateTime.parse(json['date']),
    roomId: json['room_id'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date.toIso8601String(),
    "room_id": roomId,
  };
}
