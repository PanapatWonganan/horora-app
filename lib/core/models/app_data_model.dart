class AppData {
  final List<FaqItem> faqItems;
  final List<AppUpdate> appUpdates;
  final List<Testimonial> testimonials;
  final List<SupportContact> supportContacts;
  final List<PrivacyPolicySection> privacyPolicy;
  final List<TermsOfServiceSection> termsOfService;
  final DateTime lastUpdated;

  AppData({
    required this.faqItems,
    required this.appUpdates,
    required this.testimonials,
    required this.supportContacts,
    required this.privacyPolicy,
    required this.termsOfService,
    required this.lastUpdated,
  });

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      faqItems: (json['faq_items'] as List)
          .map((item) => FaqItem.fromJson(item))
          .toList(),
      appUpdates: (json['app_updates'] as List)
          .map((update) => AppUpdate.fromJson(update))
          .toList(),
      testimonials: (json['testimonials'] as List)
          .map((testimonial) => Testimonial.fromJson(testimonial))
          .toList(),
      supportContacts: (json['support_contacts'] as List)
          .map((contact) => SupportContact.fromJson(contact))
          .toList(),
      privacyPolicy: (json['privacy_policy'] as List)
          .map((section) => PrivacyPolicySection.fromJson(section))
          .toList(),
      termsOfService: (json['terms_of_service'] as List)
          .map((section) => TermsOfServiceSection.fromJson(section))
          .toList(),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'faq_items': faqItems.map((item) => item.toJson()).toList(),
      'app_updates': appUpdates.map((update) => update.toJson()).toList(),
      'testimonials': testimonials.map((testimonial) => testimonial.toJson()).toList(),
      'support_contacts': supportContacts.map((contact) => contact.toJson()).toList(),
      'privacy_policy': privacyPolicy.map((section) => section.toJson()).toList(),
      'terms_of_service': termsOfService.map((section) => section.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class FaqItem {
  final int id;
  final String question;
  final String questionTh;
  final String answer;
  final String answerTh;
  final String category;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  FaqItem({
    required this.id,
    required this.question,
    required this.questionTh,
    required this.answer,
    required this.answerTh,
    required this.category,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: json['id'],
      question: json['question'],
      questionTh: json['question_th'],
      answer: json['answer'],
      answerTh: json['answer_th'],
      category: json['category'],
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'question_th': questionTh,
      'answer': answer,
      'answer_th': answerTh,
      'category': category,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AppUpdate {
  final int id;
  final String version;
  final String title;
  final String titleTh;
  final String description;
  final String descriptionTh;
  final bool isMandatory;
  final String? downloadUrl;
  final DateTime releaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUpdate({
    required this.id,
    required this.version,
    required this.title,
    required this.titleTh,
    required this.description,
    required this.descriptionTh,
    required this.isMandatory,
    this.downloadUrl,
    required this.releaseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    return AppUpdate(
      id: json['id'],
      version: json['version'],
      title: json['title'],
      titleTh: json['title_th'],
      description: json['description'],
      descriptionTh: json['description_th'],
      isMandatory: json['is_mandatory'],
      downloadUrl: json['download_url'],
      releaseDate: DateTime.parse(json['release_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'title': title,
      'title_th': titleTh,
      'description': description,
      'description_th': descriptionTh,
      'is_mandatory': isMandatory,
      'download_url': downloadUrl,
      'release_date': releaseDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Testimonial {
  final int id;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final String commentTh;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Testimonial({
    required this.id,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.commentTh,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'],
      userName: json['user_name'],
      userImage: json['user_image'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      commentTh: json['comment_th'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_image': userImage,
      'rating': rating,
      'comment': comment,
      'comment_th': commentTh,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class SupportContact {
  final int id;
  final String type;
  final String value;
  final String? description;
  final String? descriptionTh;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportContact({
    required this.id,
    required this.type,
    required this.value,
    this.description,
    this.descriptionTh,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportContact.fromJson(Map<String, dynamic> json) {
    return SupportContact(
      id: json['id'],
      type: json['type'],
      value: json['value'],
      description: json['description'],
      descriptionTh: json['description_th'],
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'value': value,
      'description': description,
      'description_th': descriptionTh,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PrivacyPolicySection {
  final int id;
  final String title;
  final String titleTh;
  final String content;
  final String contentTh;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrivacyPolicySection({
    required this.id,
    required this.title,
    required this.titleTh,
    required this.content,
    required this.contentTh,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrivacyPolicySection.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicySection(
      id: json['id'],
      title: json['title'],
      titleTh: json['title_th'],
      content: json['content'],
      contentTh: json['content_th'],
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_th': titleTh,
      'content': content,
      'content_th': contentTh,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TermsOfServiceSection {
  final int id;
  final String title;
  final String titleTh;
  final String content;
  final String contentTh;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  TermsOfServiceSection({
    required this.id,
    required this.title,
    required this.titleTh,
    required this.content,
    required this.contentTh,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TermsOfServiceSection.fromJson(Map<String, dynamic> json) {
    return TermsOfServiceSection(
      id: json['id'],
      title: json['title'],
      titleTh: json['title_th'],
      content: json['content'],
      contentTh: json['content_th'],
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_th': titleTh,
      'content': content,
      'content_th': contentTh,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 