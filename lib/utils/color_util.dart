import 'dart:ui';

Color hexToColor(String hex) {
  hex = hex.replaceAll("#", "");
  return Color(int.parse("0xFF$hex"));
}
