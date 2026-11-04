// Only paired, nonempty double tildes mark strikethrough. Unmatched tildes
// such as the existing Chinese farewell "再见~~！" remain literal.
final _strikethroughPattern = RegExp(r'~~(.+?)~~', dotAll: true);

Iterable<RegExpMatch> narrativeStrikethroughMatches(String text) =>
    _strikethroughPattern.allMatches(text);

/// Search and accessibility text keep the words without formatting markers.
String narrativePlainText(String text) =>
    text.replaceAllMapped(_strikethroughPattern, (match) => match.group(1)!);
