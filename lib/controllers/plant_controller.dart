import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant_model.dart';

const _kPlantsKey = 'plants_data';

class PlantController extends GetxController {
  final RxList<Plant> plants = <Plant>[].obs;
  final RxInt currentTab = 0.obs;
  final RxSet<int> justWatered = <int>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPlants();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _loadPlants() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kPlantsKey);
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        plants.assignAll(jsonList.map((e) => Plant.fromJson(e)).toList());
      } else {
        _loadSamplePlants();
      }
    } catch (_) {
      _loadSamplePlants();
    }
    isLoading.value = false;
  }

  Future<void> _savePlants() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(plants.map((p) => p.toJson()).toList());
    await prefs.setString(_kPlantsKey, jsonStr);
  }

  void _loadSamplePlants() {
    plants.assignAll([
      Plant(
        id: 1,
        name: 'Monstera',
        nickname: 'Big Guy',
        emoji: '🌿',
        room: 'Living Room',
        light: 'Indirect',
        waterIntervalDays: 7,
        lastWatered: DateTime.now().subtract(const Duration(days: 5)),
        color: '#4a7c59',
      ),
      Plant(
        id: 2,
        name: 'Cactus',
        nickname: 'Spike',
        emoji: '🌵',
        room: 'Windowsill',
        light: 'Full Sun',
        waterIntervalDays: 21,
        lastWatered: DateTime.now().subtract(const Duration(days: 3)),
        color: '#8b6f47',
      ),
      Plant(
        id: 3,
        name: 'Peace Lily',
        nickname: 'Lily',
        emoji: '🌸',
        room: 'Bedroom',
        light: 'Low Light',
        waterIntervalDays: 5,
        lastWatered: DateTime.now().subtract(const Duration(days: 5)),
        color: '#c47c5a',
      ),
      Plant(
        id: 4,
        name: 'Pothos',
        nickname: 'Viny',
        emoji: '🍃',
        room: 'Kitchen',
        light: 'Any',
        waterIntervalDays: 10,
        lastWatered: DateTime.now().subtract(const Duration(days: 1)),
        color: '#2d6a4f',
      ),
      Plant(
        id: 5,
        name: 'Snake Plant',
        nickname: 'Sandy',
        emoji: '🌱',
        room: 'Office',
        light: 'Low Light',
        waterIntervalDays: 14,
        lastWatered: DateTime.now().subtract(const Duration(days: 9)),
        color: '#6b8f71',
      ),
    ]);
    _savePlants();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void waterPlant(int id) {
    final index = plants.indexWhere((p) => p.id == id);
    if (index == -1) return;
    plants[index] = plants[index].copyWith(lastWatered: DateTime.now());
    plants.refresh();
    _savePlants();

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
  }) {
    final newId = plants.isEmpty
        ? 1
        : plants.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    plants.add(Plant(
      id: newId,
      name: name,
      nickname: nickname,
      emoji: emoji,
      room: room,
      light: light,
      waterIntervalDays: waterIntervalDays,
      lastWatered: DateTime.now(),
      photoPath: photoPath,
    ));
    _savePlants();
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
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  List<Plant> get criticalPlants =>
      plants.where((p) => p.urgency == WaterUrgency.critical).toList();

  List<Plant> get upcomingPlants =>
      plants.where((p) => p.urgency != WaterUrgency.critical).toList();

  int get totalWaterings => 14;
  int get streakDays => 3;

  void changeTab(int index) => currentTab.value = index;
}
