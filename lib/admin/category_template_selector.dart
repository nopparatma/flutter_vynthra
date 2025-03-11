import 'package:flutter/material.dart';

class CategoryTemplateSelector extends StatelessWidget {
  final Function(String thaiCategory, String englishCategory) onSelectTemplate;

  const CategoryTemplateSelector({
    Key? key,
    required this.onSelectTemplate,
  }) : super(key: key);

  // Predefined category templates
  final List<Map<String, String>> _categoryTemplates = const [
    {'th': 'บุคลิกลักษณะและอุปนิสัย', 'en': 'Personality and Characteristics'},
    {'th': 'การงานและอาชีพ', 'en': 'Career and Occupation'},
    {'th': 'การเงิน', 'en': 'Finance'},
    {'th': 'สิ่งที่ควรระวัง', 'en': 'Cautions'},
    {'th': 'ความรักและคู่ครอง', 'en': 'Love and Partnership'},
    {'th': 'สุขภาพ', 'en': 'Health'},
    {'th': 'สรุป', 'en': 'Summary'},
    {'th': 'จุดเด่น', 'en': 'Strengths'},
    {'th': 'จุดอ่อน', 'en': 'Weaknesses'},
    {'th': 'คำแนะนำ', 'en': 'Advice'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('เลือกหมวดหมู่ที่ต้องการ (Select a category template)'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _categoryTemplates.length,
          itemBuilder: (context, index) {
            final template = _categoryTemplates[index];
            return ListTile(
              title: Text(template['th']!),
              subtitle: Text(template['en']!),
              onTap: () {
                onSelectTemplate(template['th']!, template['en']!);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('ยกเลิก (Cancel)'),
        ),
        TextButton(
          onPressed: () {
            // Custom category option
            onSelectTemplate('', '');
            Navigator.pop(context);
          },
          child: const Text('สร้างหมวดหมู่ใหม่ (Custom)'),
        ),
      ],
    );
  }
}

// Extension method to show the dialog
extension CategorySelectorDialogExtension on BuildContext {
  Future<void> showCategoryTemplateSelector({
    required Function(String, String) onSelectTemplate,
  }) async {
    return showDialog(
      context: this,
      builder: (context) => CategoryTemplateSelector(
        onSelectTemplate: onSelectTemplate,
      ),
    );
  }
}
