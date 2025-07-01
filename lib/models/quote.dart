class Quote {
  final String text;
  final String author;
  final String? source;
  final DateTime? date;
  final List<String> tags;
  final bool isFavorite;
  final Character? character;

  const Quote({
    required this.text,
    required this.author,
    this.source,
    this.date,
    this.tags = const [],
    this.isFavorite = false,
    this.character,
  });

  Quote copyWith({
    String? text,
    String? author,
    String? source,
    DateTime? date,
    List<String>? tags,
    bool? isFavorite,
    Character? character,
  }) {
    return Quote(
      text: text ?? this.text,
      author: author ?? this.author,
      source: source ?? this.source,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      character: character ?? this.character,
    );
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'] ?? '',
      author: json['author'] ?? '未知',
      source: json['source'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      character: json['character'] != null ? Character.fromJson(json['character']) : null,
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
      'character': character?.toJson(),
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
    return 'Quote(text: $text, author: $author, character: ${character?.name})';
  }
}

class Character {
  final String name;
  final String codename;
  final String rarity;
  final String profession;
  final String subProfession;
  final String avatarUrl;
  final String illustrationUrl;
  final String? backgroundUrl;
  final List<String> quotes;

  const Character({
    required this.name,
    required this.codename,
    required this.rarity,
    required this.profession,
    this.subProfession = '',
    required this.avatarUrl,
    required this.illustrationUrl,
    this.backgroundUrl,
    this.quotes = const [],
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] ?? '',
      codename: json['codename'] ?? '',
      rarity: json['rarity'] ?? '',
      profession: json['profession'] ?? '',
      subProfession: json['subProfession'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      illustrationUrl: json['illustrationUrl'] ?? '',
      backgroundUrl: json['backgroundUrl'],
      quotes: List<String>.from(json['quotes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'codename': codename,
      'rarity': rarity,
      'profession': profession,
      'subProfession': subProfession,
      'avatarUrl': avatarUrl,
      'illustrationUrl': illustrationUrl,
      'backgroundUrl': backgroundUrl,
      'quotes': quotes,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Character && other.name == name && other.codename == codename;
  }

  @override
  int get hashCode => name.hashCode ^ codename.hashCode;

  @override
  String toString() {
    return 'Character(name: $name, codename: $codename)';
  }
} 