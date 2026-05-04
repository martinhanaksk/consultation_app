class TimeValidationUtils {
  static String? validateSlotTimes(Duration? startTime, Duration? duration) {
    if (startTime == null) return 'Please set a start time';
    if (duration == null || duration.inMinutes == 0) {return 'Please set a duration';}
    
    return null;
  }

  static String? validateBlockCreation({
    required List<String>? selectedDates,
    required Duration? startTime,
    required Duration? duration,
    required int? slotCount,
    required Duration? endTime,
  }) {
    if (selectedDates==null) return 'Please select date';
    if (selectedDates.isEmpty) return 'Please select at least one date';
    final timeError = validateSlotTimes(startTime, duration);
    if (timeError != null) return timeError;
    if (slotCount == null || slotCount <= 0) {
      return 'Please enter a valid number of slots';
    }
    if (endTime == null && slotCount != 0) {
      return 'End time is invalid (exceeds 24h)';
    }

    return null;
  }
}
