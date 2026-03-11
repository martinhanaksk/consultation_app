class SlotModel {
  final int id;
  final int blockId;
  final String startTime;
  final int duration;
  final int valid;
  final String? takenBy;
  final String? takenByName;
  final String? takenByReason;
  final String? history;
  final String? note;
  final int isOnline;
  final int roomId;

  SlotModel({
    required this.id,
    required this.blockId,
    required this.startTime,
    required this.duration,
    required this.valid,
    this.takenBy,
    this.takenByName,
    this.takenByReason,
    this.history,
    this.note,
    required this.isOnline,
    required this.roomId,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) => SlotModel(
    id: json['id'],
    blockId: json['block_id'],
    startTime: json['start_time'],
    duration: json['duration'],
    valid: json['valid'],
    takenBy: json['taken_by'],
    takenByName: json['taken_by_name'],
    takenByReason: json['taken_by_reason'],
    history: json['history'],
    note: json['note'],
    isOnline: json['is_online'],
    roomId: json['room_id'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "block_id": blockId,
    "start_time": startTime,
    "duration": duration,
    "valid": valid,
    "taken_by": takenBy,
    "taken_by_name": takenByName,
    "taken_by_reason": takenByReason,
    "history": history,
    "note": note,
    "is_online": isOnline,
    "room_id": roomId,
  };
}
