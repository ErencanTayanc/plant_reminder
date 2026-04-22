import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/plant_model.dart';
import '../controllers/plant_controller.dart';
import '../controllers/settings_controller.dart';
import '../theme/app_theme.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PlantController>();
    final t = SettingsController.to.theme;
    final style = UrgencyStyle.of(plant.urgency);

    return Dismissible(
      key: ValueKey(plant.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await Get.dialog<bool>(
              AlertDialog(
                backgroundColor: t.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Remove ${plant.name}?', style: TextStyle(color: t.textDark)),
                content: Text('This will permanently delete this plant.', style: TextStyle(color: t.textMuted)),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text('Cancel', style: TextStyle(color: t.textMuted)),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        ctrl.deletePlant(plant.id);
        Get.snackbar(
          '🗑 Removed',
          '${plant.name} was deleted',
          backgroundColor: const Color(0xFFFFE5E5),
          colorText: const Color(0xFFC1121F),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      child: Obx(() {
        final isWatered = ctrl.justWatered.contains(plant.id);

        return GestureDetector(
          onTap: () => Get.toNamed('/plant/${plant.id}'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isWatered ? t.accent : t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(t.isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _Avatar(plant: plant, style: style),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: name + badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plant.name,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: t.textDark),
                                ),
                                Text(
                                  '"${plant.nickname}" · ${plant.room}',
                                  style: TextStyle(fontSize: 11, color: t.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isWatered ? t.accent : style.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isWatered ? '✓ Watered!' : plant.statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isWatered ? t.primary : style.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: plant.waterProgress,
                          backgroundColor: t.accent,
                          valueColor: AlwaysStoppedAnimation(style.bar),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 7),

                      // Bottom row: last watered | next watering | water button
                      Row(
                        children: [
                          // Last watered chip
                          Flexible(
                            child: _InfoChip(
                              icon: Icons.history_rounded,
                              label: plant.lastWateredLabel,
                              color: t.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Next watering chip
                          Flexible(
                            child: _InfoChip(
                              icon: Icons.event_rounded,
                              label: plant.nextWateringLabel,
                              color: style.text,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Water button (fixed size, never shrinks)
                          GestureDetector(
                            onTap: () => ctrl.waterPlant(plant.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: isWatered ? const Color(0xFF95D5B2) : t.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isWatered ? '✓' : '💧 Water',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Small info chip ──────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.max,
    children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 3),
      Flexible(
        child: Text(label, style: TextStyle(fontSize: 11, color: color), overflow: TextOverflow.ellipsis, maxLines: 1),
      ),
    ],
  );
}

// ── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final Plant plant;
  final UrgencyStyle style;
  const _Avatar({required this.plant, required this.style});

  @override
  Widget build(BuildContext context) {
    if (plant.photoPath != null) {
      final file = File(plant.photoPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(width: 52, height: 52, child: Image.file(file, fit: BoxFit.cover)),
        );
      }
    }
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: style.background, borderRadius: BorderRadius.circular(14)),
      child: Center(child: Text(plant.emoji, style: const TextStyle(fontSize: 26))),
    );
  }
}
