class SlotModel {
  final int id;
  final int blockId;
  final DateTime datetime;
  final int duration;
  final int valid;
  final String? takenBy;
  final String? history;
  final String note;

  SlotModel({
    required this.id,
    required this.blockId,
    required this.datetime,
    required this.duration,
    required this.valid,
    this.takenBy,
    this.history,
    required this.note,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) => SlotModel(
    id: json['id'],
    blockId: json['block_id'],
    datetime: DateTime.parse(json['datetime']),
    duration: json['duration'],
    valid: json['valid'],
    takenBy: json['taken_by'],
    history: json['history'],
    note: json['note'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "block_id": blockId,
    "datetime": datetime.toIso8601String(),
    "duration": duration,
    "valid": valid,
    "taken_by": takenBy,
    "history": history,
    "note": note,
  };
}
