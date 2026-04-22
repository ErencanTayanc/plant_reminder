import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant_model.dart';
import '../services/notification_service.dart';
import 'settings_controller.dart';

const _kPlantsKey       = 'plants_data';
const _kWaterCountKey   = 'total_waterings';

class PlantController extends GetxController {
  final RxList<Plant> plants    = <Plant>[].obs;
  final RxInt  currentTab       = 0.obs;
  final RxSet<int> justWatered  = <int>{}.obs;
  final RxBool isLoading        = true.obs;
  final RxInt  totalWaterings   = 0.obs;   // persisted real counter

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Plants
      final jsonStr = prefs.getString(_kPlantsKey);
      if (jsonStr != null) {
        final List<dynamic> list = jsonDecode(jsonStr);
        plants.assignAll(list.map((e) => Plant.fromJson(e)).toList());
      } else {
        _loadSamplePlants();
      }

      // Watering counter
      totalWaterings.value = prefs.getInt(_kWaterCountKey) ?? 0;
    } catch (_) {
      _loadSamplePlants();
    }
    isLoading.value = false;
  }

  Future<void> _savePlants() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kPlantsKey, jsonEncode(plants.map((p) => p.toJson()).toList()));
  }

  Future<void> _incrementWaterCount() async {
    totalWaterings.value++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWaterCountKey, totalWaterings.value);
  }

  void _loadSamplePlants() {
    plants.assignAll([
      Plant(id: 1, name: 'Monstera',    nickname: 'Big Guy', emoji: '🌿',
            room: 'Living Room', light: 'Indirect',  waterIntervalDays: 7,
            lastWatered: DateTime.now().subtract(const Duration(days: 5)),
            color: '#4a7c59', waterAmountMl: 250),
      Plant(id: 2, name: 'Cactus',      nickname: 'Spike',   emoji: '🌵',
            room: 'Windowsill',  light: 'Full Sun', waterIntervalDays: 21,
            lastWatered: DateTime.now().subtract(const Duration(days: 3)),
            color: '#8b6f47', waterAmountMl: 80),
      Plant(id: 3, name: 'Peace Lily',  nickname: 'Lily',    emoji: '🌸',
            room: 'Bedroom',     light: 'Low Light', waterIntervalDays: 5,
            lastWatered: DateTime.now().subtract(const Duration(days: 5)),
            color: '#c47c5a', waterAmountMl: 150),
      Plant(id: 4, name: 'Pothos',      nickname: 'Viny',    emoji: '🍃',
            room: 'Kitchen',     light: 'Any',       waterIntervalDays: 10,
            lastWatered: DateTime.now().subtract(const Duration(days: 1)),
            color: '#2d6a4f', waterAmountMl: 200),
      Plant(id: 5, name: 'Snake Plant', nickname: 'Sandy',   emoji: '🌱',
            room: 'Office',      light: 'Low Light', waterIntervalDays: 14,
            lastWatered: DateTime.now().subtract(const Duration(days: 9)),
            color: '#6b8f71', waterAmountMl: 120),
    ]);
    _savePlants();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void waterPlant(int id) {
    final index = plants.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final plant = plants[index];
    plants[index] = plant.copyWith(lastWatered: DateTime.now());
    plants.refresh();
    _savePlants();
    _incrementWaterCount();

    // Reschedule notification with updated plant states
    _rescheduleNotification();

    // Show confirmation notification if haptics enabled (use notification as feedback)
    final s = SettingsController.to;
    if (s.hapticsEnabled.value) {
      NotificationService().showWateredConfirmation(plant.name);
    }

    justWatered.add(id);
    Future.delayed(const Duration(seconds: 2), () => justWatered.remove(id));
  }

  void addPlant({
    required String name,
    required String nickname,
    required String emoji,
    required String room,
    required String light,
    required int waterIntervalDays,
    String? photoPath,
    double? waterAmountMl,
  }) {
    final newId = plants.isEmpty
        ? 1
        : plants.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    plants.add(Plant(
      id: newId, name: name, nickname: nickname, emoji: emoji,
      room: room, light: light, waterIntervalDays: waterIntervalDays,
      lastWatered: DateTime.now(), photoPath: photoPath,
      waterAmountMl: waterAmountMl,
    ));
    _savePlants();
    _rescheduleNotification();
  }

  void updatePlantPhoto(int id, String photoPath) {
    final index = plants.indexWhere((p) => p.id == id);
    if (index == -1) return;
    plants[index] = plants[index].copyWith(photoPath: photoPath);
    plants.refresh();
    _savePlants();
  }

  void deletePlant(int id) {
    plants.removeWhere((p) => p.id == id);
    _savePlants();
    _rescheduleNotification();
  }

  // Called by SettingsController when user changes reminder time
  void rescheduleNotificationPublic() => _rescheduleNotification();

  void _rescheduleNotification() {
    final s = SettingsController.to;
    NotificationService().scheduleDailyReminder(
      hour: s.notifHour.value,
      minute: s.notifMin.value,
      plants: plants.toList(),
    );
  }

  // ── Sorted list ───────────────────────────────────────────────────────────

  List<Plant> get sortedPlants {
    final s = SettingsController.to;
    final list = List<Plant>.from(plants);
    switch (s.sortOrder.value) {
      case SortOrder.urgency:
        list.sort((a, b) => a.daysUntilWater.compareTo(b.daysUntilWater));
      case SortOrder.name:
        list.sort((a, b) => a.name.compareTo(b.name));
      case SortOrder.room:
        list.sort((a, b) => a.room.compareTo(b.room));
      case SortOrder.dateAdded:
        list.sort((a, b) => a.id.compareTo(b.id));
    }
    return list;
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  List<Plant> get criticalPlants =>
      plants.where((p) => p.urgency == WaterUrgency.critical).toList();

  List<Plant> get upcomingPlants =>
      plants.where((p) => p.urgency != WaterUrgency.critical).toList();

  /// Plants that need water today OR are overdue
  int get needWaterTodayCount =>
      plants.where((p) => p.daysUntilWater <= 0).length;

  void changeTab(int index) => currentTab.value = index;
}
