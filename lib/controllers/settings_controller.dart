import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

const _kThemeKey = 'selected_theme';
const _kNameKey = 'user_name';
const _kSortKey = 'sort_order';
const _kNotifHourKey = 'notif_hour';
const _kNotifMinKey = 'notif_min';
const _kWeekStartKey = 'week_start_monday';
const _kHapticsKey = 'haptics_enabled';
const _kShowStreakKey = 'show_streak';
const _kWaterUnitKey = 'water_unit';

enum SortOrder { urgency, name, room, dateAdded }

enum WaterUnit { none, ml, oz }

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  final RxInt themeIndex = 0.obs;
  final RxString userName = ''.obs;
  final Rx<SortOrder> sortOrder = SortOrder.urgency.obs;
  final RxInt notifHour = 9.obs;
  final RxInt notifMin = 0.obs;
  final RxBool weekStartMonday = true.obs;
  final RxBool hapticsEnabled = true.obs;
  final RxBool showStreak = true.obs;
  final Rx<WaterUnit> waterUnit = WaterUnit.none.obs;

  PlantThemeData get theme => AppThemes.all[themeIndex.value];

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    themeIndex.value = (prefs.getInt(_kThemeKey) ?? 0).clamp(0, AppThemes.all.length - 1);
    userName.value = prefs.getString(_kNameKey) ?? '';
    sortOrder.value = SortOrder.values[prefs.getInt(_kSortKey) ?? 0];
    notifHour.value = prefs.getInt(_kNotifHourKey) ?? 9;
    notifMin.value = prefs.getInt(_kNotifMinKey) ?? 0;
    weekStartMonday.value = prefs.getBool(_kWeekStartKey) ?? true;
    hapticsEnabled.value = prefs.getBool(_kHapticsKey) ?? true;
    showStreak.value = prefs.getBool(_kShowStreakKey) ?? true;
    waterUnit.value = WaterUnit.values[prefs.getInt(_kWaterUnitKey) ?? 0];
  }

  Future<void> setTheme(int index) async {
    themeIndex.value = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeKey, index);
  }

  Future<void> setUserName(String name) async {
    userName.value = name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNameKey, name.trim());
  }

  Future<void> setSortOrder(SortOrder order) async {
    sortOrder.value = order;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSortKey, order.index);
  }

  Future<void> setNotifTime(int hour, int min) async {
    notifHour.value = hour;
    notifMin.value = min;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kNotifHourKey, hour);
    await prefs.setInt(_kNotifMinKey, min);
    // Reschedule notification with new time
    try {
      final plantCtrl = Get.find();
      // ignore: avoid_dynamic_calls
      plantCtrl.rescheduleNotificationPublic();
    } catch (_) {}
  }

  Future<void> setWeekStartMonday(bool val) async {
    weekStartMonday.value = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kWeekStartKey, val);
  }

  Future<void> setHaptics(bool val) async {
    hapticsEnabled.value = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHapticsKey, val);
  }

  Future<void> setShowStreak(bool val) async {
    showStreak.value = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowStreakKey, val);
  }

  Future<void> setWaterUnit(WaterUnit unit) async {
    waterUnit.value = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWaterUnitKey, unit.index);
  }

  String get notifTimeLabel {
    final h = notifHour.value;
    final m = notifMin.value.toString().padLeft(2, '0');
    //final period = h >= 12 ? 'PM' : 'AM';
    //final hour = h % 12 == 0 ? 12 : h % 12;
    return '$h:$m';
  }

  String get sortOrderLabel {
    switch (sortOrder.value) {
      case SortOrder.urgency:
        return 'Most Urgent First';
      case SortOrder.name:
        return 'Name (A–Z)';
      case SortOrder.room:
        return 'By Room';
      case SortOrder.dateAdded:
        return 'Date Added';
    }
  }

  String get waterUnitLabel {
    switch (waterUnit.value) {
      case WaterUnit.none:
        return 'None';
      case WaterUnit.ml:
        return 'Milliliters (ml)';
      case WaterUnit.oz:
        return 'Ounces (oz)';
    }
  }

  /// Short unit string used when displaying plant water amounts
  String get waterUnitShort {
    switch (waterUnit.value) {
      case WaterUnit.none:
        return 'none';
      case WaterUnit.ml:
        return 'ml';
      case WaterUnit.oz:
        return 'oz';
    }
  }
}
