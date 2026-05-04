class TimeUtils {
  static String formatTime(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  static String formatTimeWithSeconds(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    const seconds = '00';
    return '$hours:$minutes:$seconds';
  }

  static Duration? computeEndTime(Duration start, Duration slotDuration, int slotCount) {
    final total = Duration(minutes: start.inMinutes + slotCount * slotDuration.inMinutes);
    if (total.inHours > 23) return null;
    return total;
  }
}
