import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_reminder/services/gemini_service.dart';
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: t.primary,
          onPressed: () => _showPhotoSourceSheet(t),
          child: SvgPicture.asset(
            'assets/svg/gemini.svg',
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(t.bg, BlendMode.srcIn),
          ),
        ),
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

  // ── Step 1: Pick photo source ─────────────────────────────────────────────

  void _showPhotoSourceSheet(dynamic t) {
    final picker = ImagePicker();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(color: t.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: t.border, borderRadius: BorderRadius.circular(2)),
            ),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.local_florist, color: t.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyze Plant Health',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.textDark),
                    ),
                    Text('Powered by Gemini AI', style: TextStyle(fontSize: 12, color: t.textMuted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Camera option
            _SheetOption(
              icon: Icons.camera_alt_rounded,
              label: 'Take a Photo',
              t: t,
              onTap: () async {
                Get.back();
                final img = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (img != null) _analyzeAndShow(File(img.path), t);
              },
            ),
            const SizedBox(height: 10),

            // Gallery option
            _SheetOption(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              t: t,
              onTap: () async {
                Get.back();
                final img = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (img != null) _analyzeAndShow(File(img.path), t);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Show loading → call Gemini → show result ─────────────────────

  Future<void> _analyzeAndShow(File image, dynamic t) async {
    // Show loading sheet immediately
    Get.bottomSheet(_LoadingSheet(t: t), isDismissible: false, enableDrag: false);

    try {
      final result = await GeminiService.analyzePlant(image);
      Get.back(); // close loading
      _showResultSheet(image, result, t);
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar(
        '⚠️ Analysis Failed',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: const Color(0xFFFFE5E5),
        colorText: const Color(0xFFC1121F),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ── Step 3: Result bottom sheet ───────────────────────────────────────────

  void _showResultSheet(File image, String result, dynamic t) {
    Get.bottomSheet(_ResultSheet(image: image, result: result, t: t), isScrollControlled: true);
  }
}

// ── Loading sheet ─────────────────────────────────────────────────────────────

class _LoadingSheet extends StatelessWidget {
  final dynamic t;
  const _LoadingSheet({required this.t});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
    decoration: BoxDecoration(color: t.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(color: t.border, borderRadius: BorderRadius.circular(2)),
        ),
        CircularProgressIndicator(color: t.primary, strokeWidth: 2.5),
        const SizedBox(height: 20),
        Text('Analyzing your plant…', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textDark)),
        const SizedBox(height: 6),
        Text('Gemini is checking health status', style: TextStyle(fontSize: 13, color: t.textMuted)),
        const SizedBox(height: 8),
      ],
    ),
  );
}

// ── Result sheet ──────────────────────────────────────────────────────────────

class _ResultSheet extends StatelessWidget {
  final File image;
  final String result;
  final dynamic t;
  const _ResultSheet({required this.image, required this.result, required this.t});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (_, controller) => Container(
            decoration: BoxDecoration(color: t.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: t.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.local_florist, color: t.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plant Health Report',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.textDark),
                        ),
                        Text('Powered by Gemini AI', style: TextStyle(fontSize: 12, color: t.textMuted)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Photo thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(image, height: 180, width: double.infinity, fit: BoxFit.contain),
                ),
                const SizedBox(height: 16),

                // Result card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: t.border),
                  ),
                  child: MarkdownBody(data: result), // style: TextStyle(fontSize: 14, color: t.textDark, height: 1.6)),
                ),
                const SizedBox(height: 16),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

// ── Sheet option ──────────────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic t;
  final VoidCallback onTap;
  const _SheetOption({required this.icon, required this.label, required this.t, required this.onTap});

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
      child: Row(
        children: [
          Icon(icon, color: t.primary, size: 22),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15, color: t.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}
