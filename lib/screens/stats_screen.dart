import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/plant_controller.dart';
import '../controllers/settings_controller.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PlantController>();
    final s = SettingsController.to;

    return Obx(() {
      final t = s.theme;

      return Scaffold(
        backgroundColor: t.bg,
        body: CustomScrollView(
          slivers: [
            // ── Gradient header ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: t.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28)),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Garden Stats',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Your plant care overview',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Hero number
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [t.accent, t.accent.withOpacity(0.4)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: t.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🌿 ${ctrl.plants.length}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: t.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Plants in your care',
                          style:
                              TextStyle(color: t.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  

                  // Stats grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _StatBox(
                        value: '${ctrl.criticalPlants.length}',
                        label: 'Need water today',
                        emoji: '💧',
                        t: t,
                      ),
                      _StatBox(
                        value: '${ctrl.totalWaterings}',
                        label: 'Waterings this month',
                        emoji: '🗓',
                        t: t,
                      ),
                      if (s.showStreak.value)
                        _StatBox(
                          value: '🏆',
                          label: '${ctrl.streakDays}-day streak!',
                          emoji: '',
                          t: t,
                        ),
                      
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Plant health list
                  Text(
                    'Plant Health',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: t.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...ctrl.plants.map((plant) {
                    final daysLeft = plant.daysUntilWater;
                    final health = 1 - plant.waterProgress;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: t.border),
                        ),
                        child: Row(
                          children: [
                            Text(plant.emoji,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(plant.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: t.textDark,
                                              fontSize: 14)),
                                      Text(
                                        daysLeft <= 0
                                            ? 'Overdue!'
                                            : '$daysLeft days left',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: daysLeft <= 0
                                              ? const Color(0xFFE63946)
                                              : t.primaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: health.clamp(0.0, 1.0),
                                      backgroundColor: t.accent,
                                      valueColor:
                                          AlwaysStoppedAnimation(
                                              t.primaryLight),
                                      minHeight: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  final dynamic t;
  const _StatBox(
      {required this.value,
      required this.label,
      required this.emoji,
      required this.t});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: t.primary),
            ),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: t.textMuted)),
          ],
        ),
      );
}
