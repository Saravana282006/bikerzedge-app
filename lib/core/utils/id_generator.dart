import 'dart:math';

/// Simple prototype ID generator. In production Firestore assigns document IDs.
class IdGenerator {
  IdGenerator._();

  static final Random _rnd = Random();

  static String next(String prefix) {
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final salt = _rnd.nextInt(0x7fffffff).toRadixString(36);
    return '${prefix}_${ts}_$salt';
  }
}
