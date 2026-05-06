// slot_model.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Represents a single time slot within a block.
// A slot is either free or taken by a student, and tracks the full booking state.

class SlotModel {
  final int id;
  final int blockId;
  // Start time (HH:MM:SS)
  final String startTime;
  // Duration in minutes
  final int duration;
  // Null if available
  final String? takenBy;
  // Name and surname of user, null if available
  final String? takenByName;
  // Reason of user, null if available
  final String? takenByReason;
  // JSON of emails who previously took the slot
  final String? history;
  // Optional note for the slot
  final String? note;

  // 1 = slot will be online, 0 = slot will be offline
  final int isOnline;
  // 1 = slot must be online, 0 = slot can be offline
  final int isOnlineTeacher;
  // Id of room, in which slot is located
  final int roomId;

  SlotModel({
    required this.id,
    required this.blockId,
    required this.startTime,
    required this.duration,
    this.takenBy,
    this.takenByName,
    this.takenByReason,
    this.history,
    this.note,
    required this.isOnline,
    required this.isOnlineTeacher,
    required this.roomId,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) => SlotModel(
    id: json['id'],
    blockId: json['block_id'],
    startTime: json['start_time'],
    duration: json['duration'],
    takenBy: json['taken_by'],
    takenByName: json['taken_by_name'],
    takenByReason: json['taken_by_reason'],
    history: json['history'],
    note: json['note'],
    isOnline: json['is_online'],
    isOnlineTeacher: json['teacher_is_online'],
    roomId: json['room_id'],
  );

 
}
