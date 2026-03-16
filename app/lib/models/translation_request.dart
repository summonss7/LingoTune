class TranslationRequest {
  final String text;
  final String sourceLanguage;
  final String targetLanguage;
  final String? type;
  final String? context;

  TranslationRequest({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.type,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      if (type != null) 'type': type,
      if (context != null) 'context': context,
    };
  }

  TranslationRequest copyWith({
    String? text,
    String? sourceLanguage,
    String? targetLanguage,
    String? type,
    String? context,
  }) {
    return TranslationRequest(
      text: text ?? this.text,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      type: type ?? this.type,
      context: context ?? this.context,
    );
  }
}
