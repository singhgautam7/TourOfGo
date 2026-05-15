/// Formats epoch milliseconds as "15 MAY 2026, 1:23 AM"
String formatLastUpdated(int epochMs) {
  final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final day = dt.day.toString().padLeft(2, '0');
  const months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
  final month = months[dt.month - 1];
  final year = dt.year;
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '$day $month $year, $hour:$minute $period';
}

/// Returns greeting text based on current hour.
String greetingText() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning.';
  if (hour < 17) return 'Good afternoon.';
  return 'Good evening.';
}

/// Returns relative time string like "just now", "5m ago", "2h ago", "3d ago".
String relativeTime(int epochMs) {
  final now = DateTime.now();
  final then = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final diff = now.difference(then);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatLastUpdated(epochMs);
}
