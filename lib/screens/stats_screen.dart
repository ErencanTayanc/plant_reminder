import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/plant_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/plant_model.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PlantController>();
    final s = SettingsController.to;

    return Obx(() {
      final t = s.theme;
      final needWater = ctrl.plants.where((p) => p.daysUntilWater <= 0).toList();
      final upcoming = ctrl.plants.where((p) => p.daysUntilWater == 1).toList();

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
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Summary row ──────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _BigStatCard(
                          t: t,
                          icon: Icon(Icons.eco, color: Colors.green, size: 36),
                          //emoji: '🌿',
                          value: '${ctrl.plants.length}',
                          label: 'Total Plants',
                          color: t.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BigStatCard(
                          t: t,
                          icon: Icon(Icons.water_drop, color: Colors.blue, size: 36),
                          value: '${ctrl.totalWaterings.value}',
                          label: 'Times Watered',
                          color: const Color(0xFF0096C7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Need water today ──────────────────────────────────────
                  _SectionTitle('Need Water Today', Icon(Icons.water_drop, color: Colors.blue), t),
                  if (needWater.isEmpty)
                    _EmptyState(t: t, message: 'All plants are good today! 🎉')
                  else
                    ...needWater.map(
                      (plant) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PlantStatusRow(plant: plant, t: t, ctrl: ctrl),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ── Needs water tomorrow ──────────────────────────────────
                  _SectionTitle('Tomorrow', Icon(Icons.park), t),
                  if (upcoming.isEmpty)
                    _EmptyState(t: t, message: 'Nothing due tomorrow')
                  else
                    ...upcoming.map(
                      (plant) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PlantStatusRow(plant: plant, t: t, ctrl: ctrl),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ── All plants watering schedule ──────────────────────────
                  _SectionTitle('Full Schedule', Icon(Icons.schedule), t),
                  ...(() {
                    final sorted = List<Plant>.from(ctrl.plants)
                      ..sort((a, b) => a.daysUntilWater.compareTo(b.daysUntilWater));
                    return sorted.map(
                      (plant) =>
                          Padding(padding: const EdgeInsets.only(bottom: 8), child: _ScheduleRow(plant: plant, t: t)),
                    );
                  })(),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final Icon icon;
  final dynamic t;

  const _SectionTitle(this.text, this.icon, this.t);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        IconTheme(data: IconThemeData(size: 16, color: t.textMuted), child: icon),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.textMuted, letterSpacing: 0.5)),
      ],
    ),
  );
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final dynamic t;
  final String message;
  const _EmptyState({required this.t, required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: t.accent,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: t.border),
    ),
    child: Text(message, style: TextStyle(color: t.textMuted, fontSize: 13)),
  );
}

// ── Big stat card ─────────────────────────────────────────────────────────────

class _BigStatCard extends StatelessWidget {
  final dynamic t;
  final Icon icon;
  final String value;
  final String label;
  final Color color;
  const _BigStatCard({
    required this.t,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
    decoration: BoxDecoration(
      color: t.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: t.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: t.textMuted),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ],
    ),
  );
}

// ── Plant status row (need water today) ──────────────────────────────────────

class _PlantStatusRow extends StatelessWidget {
  final Plant plant;
  final dynamic t;
  final PlantController ctrl;
  const _PlantStatusRow({required this.plant, required this.t, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final style = UrgencyStyle.of(plant.urgency);
    return Obx(() {
      final isWatered = ctrl.justWatered.contains(plant.id);
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: isWatered ? t.accent : t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isWatered ? t.border : style.bar, width: isWatered ? 1 : 1.5),
        ),
        child: Row(
          children: [
            Text(plant.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant.name, style: TextStyle(fontWeight: FontWeight.bold, color: t.textDark, fontSize: 14)),
                  Text(
                    plant.daysUntilWater < 0 ? 'Overdue by ${-plant.daysUntilWater} day(s)' : 'Due today',
                    style: TextStyle(fontSize: 12, color: style.text),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ctrl.waterPlant(plant.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isWatered ? const Color(0xFF95D5B2) : t.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isWatered ? '✓' : '💧 Water',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Schedule row ──────────────────────────────────────────────────────────────

class _ScheduleRow extends StatelessWidget {
  final Plant plant;
  final dynamic t;
  const _ScheduleRow({required this.plant, required this.t});

  @override
  Widget build(BuildContext context) {
    final style = UrgencyStyle.of(plant.urgency);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(color: style.bar, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Text(plant.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plant.name, style: TextStyle(fontWeight: FontWeight.bold, color: t.textDark, fontSize: 13)),
                Text('Last: ${plant.lastWateredLabel}', style: TextStyle(fontSize: 11, color: t.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plant.nextWateringLabel,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: style.text),
              ),
              Text(
                plant.nextWateringDate.day == DateTime.now().day && plant.nextWateringDate.month == DateTime.now().month
                    ? 'today'
                    : '${plant.nextWateringDate.day}/${plant.nextWateringDate.month}',
                style: TextStyle(fontSize: 11, color: t.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
