import 'package:flutter/material.dart';

class PredictionField {
  final TextEditingController categoryThController;
  final TextEditingController categoryEnController;
  final TextEditingController contentThController;
  final TextEditingController contentEnController;

  PredictionField({
    required this.categoryThController,
    required this.categoryEnController,
    required this.contentThController,
    required this.contentEnController,
  });
}

class PredictionFormField extends StatefulWidget {
  final int index;
  final PredictionField predictionField;
  final Function(int) onRemove;

  const PredictionFormField({
    Key? key,
    required this.index,
    required this.predictionField,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<PredictionFormField> createState() => _PredictionFormFieldState();
}

class _PredictionFormFieldState extends State<PredictionFormField> {
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
                        'Category ${widget.index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Show category name if already filled
                      if (widget.predictionField.categoryThController.text.isNotEmpty)
                        Text(
                          '(${widget.predictionField.categoryThController.text})',
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
                          controller: widget.predictionField.categoryThController,
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
                          controller: widget.predictionField.categoryEnController,
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
                    controller: widget.predictionField.contentThController,
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
                    controller: widget.predictionField.contentEnController,
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
