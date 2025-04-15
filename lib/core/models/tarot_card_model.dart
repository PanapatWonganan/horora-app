class TarotCard {
  final int id;
  final String name;
  final String nameTh;
  final String suit;
  final int number;
  final String imagePath;
  final String keywords;
  final String keywordsTh;
  final String uprightMeaning;
  final String uprightMeaningTh;
  final String reversedMeaning;
  final String reversedMeaningTh;
  final DateTime createdAt;
  final DateTime updatedAt;

  TarotCard({
    required this.id,
    required this.name,
    required this.nameTh,
    required this.suit,
    required this.number,
    required this.imagePath,
    required this.keywords,
    required this.keywordsTh,
    required this.uprightMeaning,
    required this.uprightMeaningTh,
    required this.reversedMeaning,
    required this.reversedMeaningTh,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      id: json['id'],
      name: json['name'],
      nameTh: json['name_th'],
      suit: json['suit'],
      number: json['number'],
      imagePath: json['image_path'],
      keywords: json['keywords'],
      keywordsTh: json['keywords_th'],
      uprightMeaning: json['upright_meaning'],
      uprightMeaningTh: json['upright_meaning_th'],
      reversedMeaning: json['reversed_meaning'],
      reversedMeaningTh: json['reversed_meaning_th'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_th': nameTh,
      'suit': suit,
      'number': number,
      'image_path': imagePath,
      'keywords': keywords,
      'keywords_th': keywordsTh,
      'upright_meaning': uprightMeaning,
      'upright_meaning_th': uprightMeaningTh,
      'reversed_meaning': reversedMeaning,
      'reversed_meaning_th': reversedMeaningTh,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TarotReading {
  final int id;
  final int userId;
  final String spreadType;
  final String? question;
  final List<TarotCardPosition> cards;
  final String interpretation;
  final bool isSaved;
  final DateTime createdAt;
  final DateTime updatedAt;

  TarotReading({
    required this.id,
    required this.userId,
    required this.spreadType,
    this.question,
    required this.cards,
    required this.interpretation,
    required this.isSaved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TarotReading.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cardsJson = json['cards'];
    final List<TarotCardPosition> cards = cardsJson
        .map((cardJson) => TarotCardPosition.fromJson(cardJson))
        .toList();

    return TarotReading(
      id: json['id'],
      userId: json['user_id'],
      spreadType: json['spread_type'],
      question: json['question'],
      cards: cards,
      interpretation: json['interpretation'],
      isSaved: json['is_saved'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'spread_type': spreadType,
      'question': question,
      'cards': cards.map((card) => card.toJson()).toList(),
      'interpretation': interpretation,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TarotCardPosition {
  final TarotCard card;
  final String position;
  final bool isReversed;
  final String meaning;

  TarotCardPosition({
    required this.card,
    required this.position,
    required this.isReversed,
    required this.meaning,
  });

  factory TarotCardPosition.fromJson(Map<String, dynamic> json) {
    return TarotCardPosition(
      card: TarotCard.fromJson(json['card']),
      position: json['position'],
      isReversed: json['is_reversed'],
      meaning: json['meaning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card': card.toJson(),
      'position': position,
      'is_reversed': isReversed,
      'meaning': meaning,
    };
  }
} 