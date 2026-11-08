/// A single motivational quote, shown on the home screen.
class Quote {
  const Quote({required this.text, required this.author});

  final String text;
  final String author;

  /// DummyJSON sends back {"id": 1, "quote": "...", "author": "..."}
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: (json['quote'] as String?)?.trim() ?? '',
      author: (json['author'] as String?)?.trim() ?? 'Unknown',
    );
  }

  @override
  String toString() => '"$text" - $author';
}
