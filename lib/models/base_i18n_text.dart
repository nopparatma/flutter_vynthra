class BaseI18nText {
  String th;
  String en;

  BaseI18nText({
    this.th = '',
    this.en = '',
  });

  factory BaseI18nText.fromMap(Map<String, dynamic> map) {
    return BaseI18nText(
      th: map['th'] ?? '',
      en: map['en'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'th': th,
      'en': en,
    };
  }

  String getText(String lang) {
    switch (lang) {
      case 'th':
        return th;
      case 'en':
        return en;
      default:
        return th;
    }
  }
}
