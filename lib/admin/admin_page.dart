import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'prediction_form_field.dart';

class DeityCardModel {
  final Map<String, String> name;
  final Map<String, String> cardSet;
  String imageUrl;
  List<Map<String, dynamic>> description;
  List<Map<String, dynamic>> prediction;

  DeityCardModel({
    required this.name,
    required this.cardSet,
    required this.imageUrl,
    required this.description,
    required this.prediction,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cardSet': cardSet,
      'imageUrl': imageUrl,
      'description': description,
      'prediction': prediction,
    };
  }
}

class DeityCardAdminPage extends StatefulWidget {
  const DeityCardAdminPage({Key? key}) : super(key: key);

  @override
  _DeityCardAdminPageState createState() => _DeityCardAdminPageState();
}

class _DeityCardAdminPageState extends State<DeityCardAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameThController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _cardSetThController = TextEditingController();
  final TextEditingController _cardSetEnController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  // For tracking description fields
  List<DescriptionField> descriptionFields = [];

  // For tracking prediction fields
  List<PredictionField> predictionFields = [];

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  // MongoDB connection
  mongo.Db? _db;
  final String _mongoConnectionString = 'mongodb+srv://username:692345@cluster0.ridkr.mongodb.net/vynthra';

  // Image selection
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Add initial empty fields
    addDescriptionField();
    addPredictionField();

    // Connect to MongoDB
    _connectToMongoDB();
  }

  Future<void> _connectToMongoDB() async {
    try {
      _db = await mongo.Db.create(_mongoConnectionString);
      await _db!.open();
      setState(() {
        _successMessage = 'Connected to MongoDB';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to MongoDB: $e';
      });
    }
  }

  void addDescriptionField({
    String categoryTh = '',
    String categoryEn = '',
  }) {
    setState(() {
      descriptionFields.add(
        DescriptionField(
          categoryThController: TextEditingController(text: categoryTh),
          categoryEnController: TextEditingController(text: categoryEn),
          contentThController: TextEditingController(),
          contentEnController: TextEditingController(),
        ),
      );
    });
  }

  void removeDescriptionField(int index) {
    setState(() {
      descriptionFields.removeAt(index);
    });
  }

  void addPredictionField({
    String categoryTh = '',
    String categoryEn = '',
  }) {
    setState(() {
      predictionFields.add(
        PredictionField(
          categoryThController: TextEditingController(text: categoryTh),
          categoryEnController: TextEditingController(text: categoryEn),
          contentThController: TextEditingController(),
          contentEnController: TextEditingController(),
        ),
      );
    });
  }

  void removePredictionField(int index) {
    setState(() {
      predictionFields.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _successMessage = '';
      });

      try {
        // Check if MongoDB is connected
        if (_db == null || !_db!.isConnected) {
          await _connectToMongoDB();
          if (_db == null || !_db!.isConnected) {
            throw Exception('Could not connect to MongoDB');
          }
        }

        final card = DeityCardModel(
          name: {
            'th': _nameThController.text,
            'en': _nameEnController.text,
          },
          cardSet: {
            'th': _cardSetThController.text,
            'en': _cardSetEnController.text,
          },
          imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : "imageUrl",
          description: descriptionFields
              .map((field) => {
                    'category': {
                      'th': field.categoryThController.text,
                      'en': field.categoryEnController.text,
                    },
                    'content': {
                      'th': field.contentThController.text,
                      'en': field.contentEnController.text,
                    },
                  })
              .toList(),
          prediction: predictionFields
              .map((field) => {
                    'category': {
                      'th': field.categoryThController.text,
                      'en': field.categoryEnController.text,
                    },
                    'content': {
                      'th': field.contentThController.text,
                      'en': field.contentEnController.text,
                    },
                  })
              .toList(),
        );

        // Insert into MongoDB
        final collection = _db!.collection('cards');
        await collection.insert(card.toJson());

        setState(() {
          _successMessage = 'Card added successfully to MongoDB!';
        });

        _resetForm();
      } catch (e) {
        setState(() {
          _errorMessage = 'Error submitting form: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _nameThController.clear();
    _nameEnController.clear();
    _cardSetThController.clear();
    _cardSetEnController.clear();
    _imageUrlController.clear();

    setState(() {
      _selectedImage = null;

      // Clear and reset description fields
      for (var field in descriptionFields) {
        field.categoryThController.dispose();
        field.categoryEnController.dispose();
        field.contentThController.dispose();
        field.contentEnController.dispose();
      }
      descriptionFields.clear();
      addDescriptionField();

      // Clear and reset prediction fields
      for (var field in predictionFields) {
        field.categoryThController.dispose();
        field.categoryEnController.dispose();
        field.contentThController.dispose();
        field.contentEnController.dispose();
      }
      predictionFields.clear();
      addPredictionField();
    });
  }

  void _showCategorySelector(bool isDescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDescription ? 'เลือกหมวดหมู่คำอธิบาย' : 'เลือกหมวดหมู่ทำนาย'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // กำหนดเอง
              ListTile(
                title: const Text('กำหนดเอง (Custom)'),
                onTap: () {
                  Navigator.pop(context);
                  if (isDescription) {
                    addDescriptionField();
                  } else {
                    addPredictionField();
                  }
                },
              ),
              _buildCategoryOption(context, 'บุคลิกลักษณะและอุปนิสัย', 'Personality and Characteristics', isDescription),
              _buildCategoryOption(context, 'การงานและอาชีพ', 'Career and Occupation', isDescription),
              _buildCategoryOption(context, 'การเงิน', 'Finance', isDescription),
              _buildCategoryOption(context, 'สิ่งที่ควรระวัง', 'Cautions', isDescription),
              _buildCategoryOption(context, 'ความรักและคู่ครอง', 'Love and Partnership', isDescription),
              _buildCategoryOption(context, 'สุขภาพ', 'Health', isDescription),
              _buildCategoryOption(context, 'สรุป', 'Summary', isDescription),
              _buildCategoryOption(context, 'จุดเด่น', 'Strengths', isDescription),
              _buildCategoryOption(context, 'จุดอ่อน', 'Weaknesses', isDescription),
              _buildCategoryOption(context, 'คำแนะนำ', 'Advice', isDescription),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildCategoryOption(BuildContext context, String th, String en, bool isDescription) {
    return ListTile(
      title: Text(th),
      subtitle: Text(en),
      onTap: () {
        Navigator.pop(context);
        if (isDescription) {
          addDescriptionField(categoryTh: th, categoryEn: en);
        } else {
          addPredictionField(categoryTh: th, categoryEn: en);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Deity Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Messages
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        color: Colors.red.shade100,
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    if (_successMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        color: Colors.green.shade100,
                        child: Text(
                          _successMessage,
                          style: TextStyle(color: Colors.green.shade800),
                        ),
                      ),

                    // Name Section
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Card Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _nameThController,
                              decoration: const InputDecoration(
                                labelText: 'Thai Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Thai name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _nameEnController,
                              decoration: const InputDecoration(
                                labelText: 'English Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter English name';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Card Set Section
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Card Set',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _cardSetThController,
                              decoration: const InputDecoration(
                                labelText: 'Thai Card Set',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Thai card set';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _cardSetEnController,
                              decoration: const InputDecoration(
                                labelText: 'English Card Set',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter English card set';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Image Section
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Card Image',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _imageUrlController,
                                    decoration: const InputDecoration(
                                      labelText: 'Image URL',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedImage != null) ...[
                              const SizedBox(height: 12.0),
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Image.file(_selectedImage!, fit: BoxFit.cover),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Description Section
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Descriptions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            for (int i = 0; i < descriptionFields.length; i++)
                              ContentFormField(
                                index: i,
                                titlePrefix: 'Description',
                                contentField: descriptionFields[i],
                                onRemove: removeDescriptionField,
                              ),
                            ElevatedButton.icon(
                              onPressed: () => _showCategorySelector(true),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Description'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Prediction Section
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Predictions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            for (int i = 0; i < predictionFields.length; i++)
                              ContentFormField(
                                index: i,
                                titlePrefix: 'Prediction',
                                contentField: predictionFields[i],
                                onRemove: removePredictionField,
                              ),
                            ElevatedButton.icon(
                              onPressed: () => _showCategorySelector(false),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Prediction'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Submit Button
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: const Text(
                            'SUBMIT TO MONGODB',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameThController.dispose();
    _nameEnController.dispose();
    _cardSetThController.dispose();
    _cardSetEnController.dispose();
    _imageUrlController.dispose();

    for (var field in descriptionFields) {
      field.categoryThController.dispose();
      field.categoryEnController.dispose();
      field.contentThController.dispose();
      field.contentEnController.dispose();
    }

    for (var field in predictionFields) {
      field.categoryThController.dispose();
      field.categoryEnController.dispose();
      field.contentThController.dispose();
      field.contentEnController.dispose();
    }

    // Close MongoDB connection
    _db?.close();

    super.dispose();
  }
}

// กำหนดโครงสร้างข้อมูลสำหรับ Description และ Prediction
class ContentField {
  final TextEditingController categoryThController;
  final TextEditingController categoryEnController;
  final TextEditingController contentThController;
  final TextEditingController contentEnController;

  ContentField({
    required this.categoryThController,
    required this.categoryEnController,
    required this.contentThController,
    required this.contentEnController,
  });
}

// ใช้ ContentField เป็นพื้นฐานสำหรับทั้ง Description และ Prediction
typedef DescriptionField = ContentField;
typedef PredictionField = ContentField;

// Widget สำหรับแสดงฟอร์มของทั้ง Description และ Prediction
class ContentFormField extends StatefulWidget {
  final int index;
  final String titlePrefix;
  final ContentField contentField;
  final Function(int) onRemove;

  const ContentFormField({
    Key? key,
    required this.index,
    required this.titlePrefix,
    required this.contentField,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<ContentFormField> createState() => _ContentFormFieldState();
}

class _ContentFormFieldState extends State<ContentFormField> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.titlePrefix} ${widget.index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Show category name if already filled
                      if (widget.contentField.categoryThController.text.isNotEmpty)
                        Text(
                          '(${widget.contentField.categoryThController.text})',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => widget.onRemove(widget.index),
                    tooltip: 'Remove',
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category fields
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.contentField.categoryThController,
                          decoration: const InputDecoration(
                            labelText: 'Thai Category',
                            border: OutlineInputBorder(),
                            hintText: 'Enter category name in Thai',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Thai category';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextFormField(
                          controller: widget.contentField.categoryEnController,
                          decoration: const InputDecoration(
                            labelText: 'English Category',
                            border: OutlineInputBorder(),
                            hintText: 'Enter category name in English',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter English category';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  // Content fields
                  TextFormField(
                    controller: widget.contentField.contentThController,
                    decoration: const InputDecoration(
                      labelText: 'Thai Content',
                      border: OutlineInputBorder(),
                      hintText: 'Enter content in Thai',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Thai content';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: widget.contentField.contentEnController,
                    decoration: const InputDecoration(
                      labelText: 'English Content',
                      border: OutlineInputBorder(),
                      hintText: 'Enter content in English',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter English content';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
