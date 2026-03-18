class TimeSince {
  final DateTime lastSmoked;

  TimeSince(this.lastSmoked);

  Duration get timeElapsed {
    return DateTime.now().difference(lastSmoked);
  }

  Map<String, int> get timeComponents {
    final duration = timeElapsed;
    return {
      'days': duration.inDays,
      'hours': duration.inHours % 24,
      'minutes': duration.inMinutes % 60,
    };
  }
}
