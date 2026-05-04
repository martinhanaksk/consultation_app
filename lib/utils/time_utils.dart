// time_utils.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Time formatting and calculation utilities used when creating blocks and slots.

class TimeUtils {
  // Returns "HH:mm" from a Duration (e.g. Duration(hours:9, minutes:5) → "09:05")
  static String formatTime(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Returns "HH:mm:00" — seconds are always zero because slot times have minute precision
  static String formatTimeWithSeconds(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    const seconds = '00';
    return '$hours:$minutes:$seconds';
  }

  // Computes the end time by adding slotcount*duration to start time
  // Returns null if the result would exceed 23:59 (same-day constraint)
  static Duration? computeEndTime(
    Duration start,
    Duration slotDuration,
    int slotCount,
  ) {
    final total = Duration(
      minutes: start.inMinutes + slotCount * slotDuration.inMinutes,
    );
    if (total.inHours > 23) return null;
    return total;
  }
}
