class BlockModel {
  final int id;
  final DateTime date;
  final int roomId;
  final int isOnline;

  BlockModel({required this.id, required this.date, required this.roomId, required this.isOnline});

  factory BlockModel.fromJson(Map<String, dynamic> json) => BlockModel(
    id: json['id'],
    date: DateTime.parse(json['date']),
    roomId: json['room_id'],  isOnline: json['is_online'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date.toIso8601String(),
    "room_id": roomId,"is_online": isOnline,
  };
}
