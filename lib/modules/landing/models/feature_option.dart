import 'package:flutter/widgets.dart';

class FeatureOption {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const FeatureOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
}
