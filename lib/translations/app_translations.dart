import 'en.dart';
import 'tr.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en': en, 'tr': tr};
}
