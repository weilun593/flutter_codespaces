class NoteContent {
  NoteContent._();

  static final _imagePattern = RegExp(r'\[\[note-image:(https?://[^\]\s]+)\]\]');

  static List<String> imageUrls(String content) => _imagePattern
      .allMatches(content)
      .map((match) => match.group(1)!)
      .toList();

  static String text(String content) => content
      .replaceAll(_imagePattern, '')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  static String withImages(String text, List<String> urls) {
    final body = text.trim();
    if (urls.isEmpty) return body;
    final references = urls.map((url) => '[[note-image:$url]]').join('\n');
    return body.isEmpty ? references : '$body\n\n$references';
  }
}