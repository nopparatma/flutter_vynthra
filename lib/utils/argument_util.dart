import 'package:get/get.dart';

class ArgumentUtil {
  static T getArgument<T>(String key, {required T defaultValue}) {
    final args = Get.arguments;

    if (args != null && args.containsKey(key)) {
      return args[key] as T;
    }

    return defaultValue;
  }
}
