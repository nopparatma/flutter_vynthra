import 'package:mongo_dart/mongo_dart.dart';

import 'base_i18n_text.dart';

class PositionModel {
  String id;
  int seq;
  BaseI18nText name;
  String imageUrl;
  List<PositionDescription> description;

  PositionModel({
    this.id = '',
    required this.seq,
    required this.name,
    this.imageUrl = '',
    required this.description,
  });

  factory PositionModel.fromMap(Map<String, dynamic> map) {
    final id = map['_id'] is ObjectId ? (map['_id'] as ObjectId).oid : map['_id']?.toString() ?? '';

    List<PositionDescription> descriptionList = [];
    if (map['description'] != null && map['description'] is List) {
      descriptionList = (map['description'] as List).map((item) => PositionDescription.fromMap(item)).toList();
    }

    return PositionModel(
      id: id,
      seq: map['seq'] ?? 0,
      name: BaseI18nText.fromMap(map['name'] ?? {}),
      imageUrl: map['imageUrl'] ?? '',
      description: descriptionList,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'seq': seq,
      'name': name.toMap(),
      'imageUrl': imageUrl,
      'description': description.map((desc) => desc.toMap()).toList(),
    };

    if (id.isNotEmpty) {
      map['_id'] = ObjectId.parse(id);
    }

    return map;
  }

  PositionModel copyWith({
    int? seq,
    BaseI18nText? name,
    String? imageUrl,
    List<PositionDescription>? description,
  }) {
    return PositionModel(
      id: id,
      seq: seq ?? this.seq,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  /// รวมข้อความจาก description ทั้งหมดของตำแหน่ง
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

  /// รวมข้อความทั้งหมดของตำแหน่งเป็นฉบับเต็ม
  ///
  /// [lang] - ภาษาที่ต้องการให้แสดง ('th', 'en')
  String getFullText({required String lang}) {
    final List<String> sections = [];

    // ชื่อตำแหน่ง
    final positionName = name.getText(lang);
    if (positionName.isNotEmpty) {
      sections.add('# $positionName');
    }

    // คำอธิบาย
    final descText = getDescriptionText(lang: lang);
    if (descText.isNotEmpty) {
      sections.add(descText);
    }

    return sections.join('\n\n');
  }
}

class PositionDescription {
  BaseI18nText category;
  BaseI18nText content;

  PositionDescription({
    required this.category,
    required this.content,
  });

  factory PositionDescription.fromMap(Map<String, dynamic> map) {
    return PositionDescription(
      category: BaseI18nText.fromMap(map['category'] ?? {}),
      content: BaseI18nText.fromMap(map['content'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category.toMap(),
      'content': content.toMap(),
    };
  }
}
