class Quote {
  final String text;
  final String author;
  final String? source;
  final DateTime? date;
  final List<String> tags;
  final bool isFavorite;

  const Quote({
    required this.text,
    this.author = '',
    this.source,
    this.date,
    this.tags = const [],
    this.isFavorite = false,
  });

  Quote copyWith({
    String? text,
    String? author,
    String? source,
    DateTime? date,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Quote(
      text: text ?? this.text,
      author: author ?? this.author,
      source: source ?? this.source,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['content'] ?? json['text'] ?? '', // Support for 'content' or 'text' key
      author: json['author'] ?? '未知',
      source: json['source'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
      'source': source,
      'date': date?.toIso8601String(),
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quote && other.text == text && other.author == author;
  }

  @override
  int get hashCode => text.hashCode ^ author.hashCode;

  @override
  String toString() {
    return 'Quote(text: $text, author: $author)';
  }
} 