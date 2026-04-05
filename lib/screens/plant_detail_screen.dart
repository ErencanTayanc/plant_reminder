import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/plant_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/plant_model.dart';
import '../theme/app_theme.dart';

class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PlantController>();
    final s = SettingsController.to;
    final int id = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;

    return Obx(() {
      final t = s.theme;
      final plant = ctrl.plants.firstWhereOrNull((p) => p.id == id);
      if (plant == null) {
        return Scaffold(
            backgroundColor: t.bg,
            body: Center(child: Text('Plant not found',
                style: TextStyle(color: t.textMuted))));
      }

      final style = UrgencyStyle.of(plant.urgency);
      final isWatered = ctrl.justWatered.contains(plant.id);

      return Scaffold(
        backgroundColor: t.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: t.bg,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                onPressed: () => Get.back(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  onPressed: () => _showPhotoSheet(ctrl, plant, t),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () => _confirmDelete(ctrl, plant, t),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _HeroArea(plant: plant, style: style, t: t),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: isWatered ? t.accent : style.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isWatered ? '✓ Just Watered!' : plant.statusLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isWatered ? t.primary : style.text,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _InfoCell('Room', plant.room, t),
                        _InfoCell('Light', plant.light, t),
                        _InfoCell('Frequency', 'Every ${plant.waterIntervalDays} days', t),
                        _InfoCell('Last Watered', '${plant.daysSinceWatered}d ago', t),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _Card(t: t, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Water Level',
                                style: TextStyle(fontWeight: FontWeight.bold,
                                    color: t.textDark, fontSize: 14)),
                            Text('${(plant.waterProgress * 100).toInt()}%',
                                style: TextStyle(fontWeight: FontWeight.bold,
                                    color: style.text, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: plant.waterProgress,
                            backgroundColor: t.accent,
                            valueColor: AlwaysStoppedAnimation(style.bar),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plant.daysUntilWater <= 0
                              ? 'Overdue by ${-plant.daysUntilWater} day(s)!'
                              : '${plant.daysUntilWater} days until next watering',
                          style: TextStyle(fontSize: 12, color: style.text),
                        ),
                      ],
                    )),
                    const SizedBox(height: 12),

                    _Card(t: t, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('This Week',
                            style: TextStyle(fontWeight: FontWeight.bold,
                                color: t.textDark, fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                              .asMap()
                              .entries
                              .map((e) {
                            final isToday = e.key == DateTime.now().weekday - 1;
                            return Column(children: [
                              Text(e.value,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: isToday ? t.primary : t.textMuted,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                              const SizedBox(height: 6),
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isToday ? t.primary : t.accent,
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ],
                    )),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isWatered ? null : () => ctrl.waterPlant(id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isWatered
                              ? const Color(0xFF95D5B2)
                              : t.primary,
                          disabledBackgroundColor: const Color(0xFF95D5B2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          isWatered ? '✓ Watered!' : '💧 Water ${plant.name} Now',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showPhotoSheet(PlantController ctrl, Plant plant, dynamic t) {
    final picker = ImagePicker();
    Get.bottomSheet(Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: t.border, borderRadius: BorderRadius.circular(2))),
          Text('Update photo',
              style: TextStyle(fontSize: 17,
                  fontWeight: FontWeight.bold, color: t.textDark)),
          const SizedBox(height: 16),
          _SheetOption(icon: Icons.camera_alt_rounded, label: 'Take a photo',
              t: t, onTap: () async {
            Get.back();
            final img = await picker.pickImage(source: ImageSource.camera,
                maxWidth: 800, maxHeight: 800, imageQuality: 85);
            if (img != null) ctrl.updatePlantPhoto(plant.id, img.path);
          }),
          const SizedBox(height: 10),
          _SheetOption(icon: Icons.photo_library_rounded, label: 'Choose from gallery',
              t: t, onTap: () async {
            Get.back();
            final img = await picker.pickImage(source: ImageSource.gallery,
                maxWidth: 800, maxHeight: 800, imageQuality: 85);
            if (img != null) ctrl.updatePlantPhoto(plant.id, img.path);
          }),
        ],
      ),
    ));
  }

  void _confirmDelete(PlantController ctrl, Plant plant, dynamic t) {
    Get.dialog(AlertDialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Remove ${plant.name}?',
          style: TextStyle(color: t.textDark, fontWeight: FontWeight.bold)),
      content: Text('This will permanently delete this plant.',
          style: TextStyle(color: t.textMuted)),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel', style: TextStyle(color: t.textMuted)),
        ),
        ElevatedButton(
          onPressed: () { ctrl.deletePlant(plant.id); Get.back(); Get.back(); },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}

class _HeroArea extends StatelessWidget {
  final Plant plant;
  final UrgencyStyle style;
  final dynamic t;
  const _HeroArea({required this.plant, required this.style, required this.t});

  @override
  Widget build(BuildContext context) {
    if (plant.photoPath != null) {
      final file = File(plant.photoPath!);
      if (file.existsSync()) {
        return Stack(fit: StackFit.expand, children: [
          Image.file(file, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC1A3C2E)],
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 20,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plant.name,
                  style: const TextStyle(fontSize: 26,
                      fontWeight: FontWeight.bold, color: Colors.white)),
              Text('"${plant.nickname}"',
                  style: const TextStyle(fontSize: 14,
                      color: Colors.white70, fontStyle: FontStyle.italic)),
            ]),
          ),
        ]);
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: t.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(plant.emoji, style: const TextStyle(fontSize: 72)),
        const SizedBox(height: 8),
        Text(plant.name,
            style: const TextStyle(fontSize: 26,
                fontWeight: FontWeight.bold, color: Colors.white)),
        Text('"${plant.nickname}"',
            style: const TextStyle(fontSize: 14,
                color: Colors.white70, fontStyle: FontStyle.italic)),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final dynamic t;
  final Widget child;
  const _Card({required this.t, required this.child});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: child);
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final dynamic t;
  const _InfoCell(this.label, this.value, this.t);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: t.textMuted)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(fontSize: 15,
                fontWeight: FontWeight.bold, color: t.textDark)),
          ]));
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic t;
  final VoidCallback onTap;
  const _SheetOption({required this.icon, required this.label,
      required this.t, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.border),
          ),
          child: Row(children: [
            Icon(icon, color: t.primary, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(fontSize: 15,
                    color: t.primary, fontWeight: FontWeight.w600)),
          ])));
}
