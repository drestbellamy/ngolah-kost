/// Utility class for date formatting in Penghuni module
class PenghuniDateFormatter {
  static const List<String> _monthNamesShort = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _monthNamesFull = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Format date from raw value (string or DateTime)
  /// Returns format: "1 Jan 2024"
  static String formatDateFromRaw(dynamic value) {
    final dt = DateTime.tryParse(value?.toString() ?? '');
    if (dt == null) return '-';

    return '${dt.day} ${_monthNamesShort[dt.month]} ${dt.year}';
  }

  /// Format month label
  /// Returns format: "Januari 2024"
  static String formatMonthLabel(DateTime date) {
    return '${_monthNamesFull[date.month]} ${date.year}';
  }

  /// Format periode label based on payment cycle
  /// Returns format: "Januari 2024" for 1 month or "Januari-Maret 2024" for 3 months
  static String formatPeriodeLabel(DateTime start, int siklusBulan) {
    if (siklusBulan <= 1) {
      return formatMonthLabel(start);
    }

    final end = DateTime(start.year, start.month + siklusBulan - 1, start.day);
    return '${_monthNamesFull[start.month]}-\n${_monthNamesFull[end.month]} ${end.year}';
  }

  /// Format due date
  /// Returns format: "01 Januari 2024"
  static String formatDueDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthNamesFull[date.month]} ${date.year}';
  }

  /// Parse date string to DateTime
  /// Accepts format: "1 Jan 2024" or "1 Januari 2024"
  static DateTime? parseDate(String tanggal) {
    final parts = tanggal.split(RegExp(r'\s+'));
    if (parts.length < 3) return null;

    final day = int.tryParse(parts[0]);
    final month = _monthNumber(parts[1].toLowerCase());
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  /// Get month number from month name
  static int? _monthNumber(String monthName) {
    final normalized = monthName.toLowerCase();

    // Check short names
    for (var i = 1; i < _monthNamesShort.length; i++) {
      if (_monthNamesShort[i].toLowerCase() == normalized) {
        return i;
      }
    }

    // Check full names
    for (var i = 1; i < _monthNamesFull.length; i++) {
      if (_monthNamesFull[i].toLowerCase() == normalized) {
        return i;
      }
    }

    return null;
  }

  /// Convert dynamic value to int
  static int toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Convert dynamic value to double
  static double toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
