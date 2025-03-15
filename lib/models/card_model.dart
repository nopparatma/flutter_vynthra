import 'package:mongo_dart/mongo_dart.dart';

import 'base_i18n_text.dart';

class CardModel {
  String id;
  BaseI18nText name;
  BaseI18nText cardSet;
  String imageUrl;
  List<Description> description;
  List<Description> prediction;

  CardModel({
    this.id = '',
    required this.name,
    required this.cardSet,
    this.imageUrl = '',
    required this.description,
    required this.prediction,
  });

  factory CardModel.fromMap(Map<String, dynamic> map) {
    final id = map['_id'] is ObjectId ? (map['_id'] as ObjectId).oid : map['_id']?.toString() ?? '';

    List<Description> descriptionList = [];
    if (map['description'] != null && map['description'] is List) {
      descriptionList = (map['description'] as List).map((item) => Description.fromMap(item)).toList();
    }

    List<Description> predictionList = [];
    if (map['prediction'] != null && map['prediction'] is List) {
      predictionList = (map['prediction'] as List).map((item) => Description.fromMap(item)).toList();
    }

    return CardModel(
      id: id,
      name: BaseI18nText.fromMap(map['name'] ?? {}),
      cardSet: BaseI18nText.fromMap(map['cardSet'] ?? {}),
      imageUrl: map['imageUrl'] ?? '',
      description: descriptionList,
      prediction: predictionList,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'name': name.toMap(),
      'cardSet': cardSet.toMap(),
      'imageUrl': imageUrl,
      'description': description.map((desc) => desc.toMap()).toList(),
      'prediction': prediction.map((pred) => pred.toMap()).toList(),
    };

    if (id.isNotEmpty) {
      map['_id'] = ObjectId.parse(id);
    }

    return map;
  }

  /// รวมข้อความจาก description ทั้งหมดของไพ่
  ///
  /// [lang] - ภาษาที่ต้องการให้แสดง ('th', 'en')
  /// [separator] - ตัวคั่นระหว่างแต่ละรายการ (default: '\n\n')
  /// [showCategory] - แสดงหมวดหมู่หรือไม่ (default: true)
  /// [categoryPrefix] - คำนำหน้าหมวดหมู่ (default: '## ')
  /// [categorySuffix] - คำต่อท้ายหมวดหมู่ (default: '')
  String getDescriptionText({
    required String lang,
    String separator = '\n\n',
    bool showCategory = true,
    String categoryPrefix = '## ',
    String categorySuffix = '',
  }) {
    if (description.isEmpty) {
      return '';
    }

    final List<String> texts = [];

    for (var desc in description) {
      String text = '';

      // เพิ่มหมวดหมู่ถ้าต้องการแสดง
      if (showCategory && desc.category.getText(lang).isNotEmpty) {
        text += '$categoryPrefix${desc.category.getText(lang)}$categorySuffix\n';
      }

      // เพิ่มเนื้อหา
      if (desc.content.getText(lang).isNotEmpty) {
        text += desc.content.getText(lang);
      }

      if (text.isNotEmpty) {
        texts.add(text);
      }
    }

    return texts.join(separator);
  }

  /// รวมข้อความจาก prediction ทั้งหมดของไพ่
  ///
  /// [lang] - ภาษาที่ต้องการให้แสดง ('th', 'en')
  /// [separator] - ตัวคั่นระหว่างแต่ละรายการ (default: '\n\n')
  /// [showCategory] - แสดงหมวดหมู่หรือไม่ (default: true)
  /// [categoryPrefix] - คำนำหน้าหมวดหมู่ (default: '## ')
  /// [categorySuffix] - คำต่อท้ายหมวดหมู่ (default: '')
  String getPredictionText({
    required String lang,
    String separator = '\n\n',
    bool showCategory = true,
    String categoryPrefix = '## ',
    String categorySuffix = '',
  }) {
    if (prediction.isEmpty) {
      return '';
    }

    final List<String> texts = [];

    for (var pred in prediction) {
      String text = '';

      // เพิ่มหมวดหมู่ถ้าต้องการแสดง
      if (showCategory && pred.category.getText(lang).isNotEmpty) {
        text += '$categoryPrefix${pred.category.getText(lang)}$categorySuffix\n';
      }

      // เพิ่มเนื้อหา
      if (pred.content.getText(lang).isNotEmpty) {
        text += pred.content.getText(lang);
      }

      if (text.isNotEmpty) {
        texts.add(text);
      }
    }

    return texts.join(separator);
  }

  /// รวมข้อความทั้งหมดของไพ่เป็นฉบับเต็ม
  ///
  /// [lang] - ภาษาที่ต้องการให้แสดง ('th', 'en')
  String getFullText({required String lang}) {
    final List<String> sections = [];

    // ชื่อไพ่
    final cardName = name.getText(lang);
    if (cardName.isNotEmpty) {
      sections.add('# $cardName');
    }

    // คำอธิบาย
    final descText = getDescriptionText(lang: lang);
    if (descText.isNotEmpty) {
      sections.add(descText);
    }

    // คำทำนาย
    final predText = getPredictionText(lang: lang);
    if (predText.isNotEmpty) {
      sections.add(predText);
    }

    return sections.join('\n\n');
  }
}

class Description {
  String colorCode;
  BaseI18nText category;
  BaseI18nText content;

  Description({
    required this.category,
    required this.content,
    required this.colorCode,
  });

  factory Description.fromMap(Map<String, dynamic> map) {
    return Description(
      category: BaseI18nText.fromMap(map['category'] ?? {}),
      content: BaseI18nText.fromMap(map['content'] ?? {}),
      colorCode: map['colorCode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category.toMap(),
      'content': content.toMap(),
      'colorCode': colorCode,
    };
  }
}
