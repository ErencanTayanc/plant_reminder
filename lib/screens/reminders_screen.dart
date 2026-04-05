import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/plant_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/plant_model.dart';
import '../theme/app_theme.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PlantController>();
    final s = SettingsController.to;

    return Obx(() {
      final t = s.theme;
      final critical = ctrl.criticalPlants;
      final upcoming = ctrl.upcomingPlants;

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
                      'Reminders',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${critical.length} urgent · ${upcoming.length} upcoming',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            if (critical.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader('TODAY', t),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ReminderCard(plant: critical[i], t: t),
                    ),
                    childCount: critical.length,
                  ),
                ),
              ),
            ],

            SliverToBoxAdapter(
              child: _SectionHeader('UPCOMING', t),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ReminderCard(plant: upcoming[i], t: t),
                  ),
                  childCount: upcoming.length,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final dynamic t;
  const _SectionHeader(this.title, this.t);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: t.textMuted,
            letterSpacing: 1.2,
          ),
        ),
      );
}

class _ReminderCard extends StatelessWidget {
  final Plant plant;
  final dynamic t;
  const _ReminderCard({required this.plant, required this.t});

  @override
  Widget build(BuildContext context) {
    final style = UrgencyStyle.of(plant.urgency);

    return GestureDetector(
      onTap: () => Get.toNamed('/plant/${plant.id}'),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: style.bar, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(plant.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant.name,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: t.textDark)),
                  const SizedBox(height: 2),
                  Text(
                    plant.urgency == WaterUrgency.critical
                        ? '🔔 Overdue · every ${plant.waterIntervalDays} days'
                        : '🔔 ${plant.statusLabel} · every ${plant.waterIntervalDays} days',
                    style:
                        TextStyle(fontSize: 12, color: t.textMuted),
                  ),
                ],
              ),
            ),
            if (plant.urgency == WaterUrgency.critical)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Now',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: style.text)),
              ),
          ],
        ),
      ),
    );
  }
}
