import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/plant_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/plant_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PlantController>();
    final s = SettingsController.to;

    return Obx(() {
      final t = s.theme;
      final critical = ctrl.criticalPlants;

      return Scaffold(
        backgroundColor: t.bg,
        body: CustomScrollView(
          slivers: [
            // ── Gradient header ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: t.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 20, right: 20, bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(s.userName.value),
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'My Plants',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/add'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Urgent banner ─────────────────────────────────────────────
            if (critical.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [t.accent, t.accent.withOpacity(0.5)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: t.border),
                    ),
                    child: Row(
                      children: [
                        const Text('💧', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${critical.length} plant${critical.length > 1 ? 's need' : ' needs'} water!',
                              style: TextStyle(fontWeight: FontWeight.bold, color: t.textDark, fontSize: 14),
                            ),
                            Text("Don't let them dry out", style: TextStyle(color: t.textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Filter pills ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 0, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        ['All', 'Urgent', 'Today', 'This Week']
                            .asMap()
                            .entries
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: e.key == 0 ? t.primary : t.accent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: e.key == 0 ? t.primary : t.border),
                                  ),
                                  child: Text(
                                    e.value,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: e.key == 0 ? Colors.white : t.primaryLight,
                                      fontWeight: e.key == 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),

            // ── Plant list ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PlantCard(plant: ctrl.sortedPlants[index]),
                  ),
                  childCount: ctrl.sortedPlants.length,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    final suffix = name.isNotEmpty ? ', $name' : '';
    if (hour < 12) return 'Good morning$suffix 🌤';
    if (hour < 17) return 'Good afternoon$suffix ☀️';
    return 'Good evening$suffix 🌙';
  }
}
