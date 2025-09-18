class NameFormatter {
  // Words you usually don't want capitalized in the middle of a name
  static const Set<String> _minorWords = {
    'a',
    'an',
    'and',
    'as',
    'at',
    'but',
    'by',
    'for',
    'from',
    'in',
    'into',
    'nor',
    'of',
    'on',
    'or',
    'per',
    'the',
    'to',
    'vs',
    'via',
  };

  // Split on space and common separators, but keep separators so we can rejoin
  static final RegExp _tokenizer = RegExp(r"([A-Za-z0-9]+|[^A-Za-z0-9]+)");

  static String titleCase(String input) {
    if (input.trim().isEmpty) return input;

    final tokens = _tokenizer
        .allMatches(input)
        .map((m) => m.group(0)!)
        .toList(growable: false);

    int wordIndex = 0; // counts only alphanumeric tokens
    final buf = StringBuffer();

    for (final t in tokens) {
      if (_isWord(t)) {
        final isFirst = wordIndex == 0;
        final isLast = _isLastWord(tokens, wordIndex);

        buf.write(_formatWord(t, isFirst: isFirst, isLast: isLast));
        wordIndex++;
      } else {
        buf.write(t); // punctuation/space as-is
      }
    }
    return buf.toString();
  }

  // ---------- helpers ----------
  static bool _isWord(String s) => RegExp(r'^[A-Za-z0-9]+$').hasMatch(s);

  static bool _isAllCaps(String s) =>
      RegExp(r'^[A-Z0-9]+$').hasMatch(s) && RegExp(r'[A-Z]').hasMatch(s);

  static bool _isMinor(String s) => _minorWords.contains(s.toLowerCase());

  static bool _isLastWord(List<String> tokens, int wordIndex) {
    int count = 0;
    for (final t in tokens) {
      if (_isWord(t)) count++;
    }
    return wordIndex == count - 1;
  }

  static String _formatWord(
    String w, {
    required bool isFirst,
    required bool isLast,
  }) {
    // 1) Already an acronym? keep it (covers SS, KK, MPL, PDF, etc.)
    if (_isAllCaps(w)) return w;

    // 2) Minor words in the middle stay lowercase
    if (!isFirst && !isLast && _isMinor(w)) return w.toLowerCase();

    // 3) Handle Mc/Mac style (optional nicety)
    final lower = w.toLowerCase();
    if (RegExp(r'^mc[a-z]').hasMatch(lower)) {
      return 'Mc${lower.substring(2, 3).toUpperCase()}${lower.substring(3)}';
    }
    if (RegExp(r'^mac[a-z]').hasMatch(lower)) {
      return 'Mac${lower.substring(3, 4).toUpperCase()}${lower.substring(4)}';
    }

    // 4) Default: first letter upper, rest lower
    return w[0].toUpperCase() + (w.length > 1 ? lower.substring(1) : '');
  }
}

extension StringTitleCaseExtension on String {
  String get titleCase => NameFormatter.titleCase(this);
}
