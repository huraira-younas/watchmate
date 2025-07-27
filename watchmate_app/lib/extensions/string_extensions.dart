extension StringX on String {
  bool get isNullOrEmpty => trim().isEmpty;
  String get capitalize {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
