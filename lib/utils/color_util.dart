import 'dart:math';
import 'dart:ui';

import 'package:get/get.dart';

Color hexToColor(String hex) {
  if (hex.isBlank ?? false) {
    final random = Random();
    final r = random.nextInt(256).toRadixString(16).padLeft(2, '0');
    final g = random.nextInt(256).toRadixString(16).padLeft(2, '0');
    final b = random.nextInt(256).toRadixString(16).padLeft(2, '0');
    hex = "$r$g$b";
  } else {
    hex = hex.replaceAll("#", "");
  }

  return Color(int.parse("0xFF$hex"));
}
