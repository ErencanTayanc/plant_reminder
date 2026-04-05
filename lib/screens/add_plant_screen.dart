import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/plant_controller.dart';
import '../controllers/settings_controller.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _nameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _intervalCtrl = TextEditingController();

  String _selectedEmoji = '🌿';
  String _selectedLight = 'Indirect';
  File? _photo;
  final _picker = ImagePicker();

  static const emojis = [
    '🌿', '🌵', '🌸', '🍃', '🌱', '🌺', '🪴', '🌻', '🎍', '🌾',
    '🌴', '🎋', '🌼', '🌷', '🌹', '🍀', '☘️', '🪷', '🫧', '🍁',
    '🎄', '🎑', '🪸', '🌲', '🌳', '🪨', '🌊', '🏵️', '🌑', '🪻',
  ];

  static const lightOptions = ['Full Sun', 'Indirect', 'Low Light', 'Any'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _roomCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
          source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (picked != null) setState(() => _photo = File(picked.path));
    } catch (_) {
      Get.snackbar('Camera error', 'Could not access camera or gallery.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFE5E5),
          colorText: const Color(0xFFC1121F));
    }
  }

  void _showPhotoSheet(dynamic t) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: t.border, borderRadius: BorderRadius.circular(2)),
            ),
            Text('Add a photo',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: t.textDark)),
            const SizedBox(height: 16),
            _SheetOption(icon: Icons.camera_alt_rounded, label: 'Take a photo',
                t: t, onTap: () { Get.back(); _pickImage(ImageSource.camera); }),
            const SizedBox(height: 10),
            _SheetOption(icon: Icons.photo_library_rounded, label: 'Choose from gallery',
                t: t, onTap: () { Get.back(); _pickImage(ImageSource.gallery); }),
            if (_photo != null) ...[
              const SizedBox(height: 10),
              _SheetOption(icon: Icons.delete_outline, label: 'Remove photo',
                  t: t, color: Colors.redAccent,
                  onTap: () { Get.back(); setState(() => _photo = null); }),
            ],
          ],
        ),
      ),
    );
  }

  void _submit(dynamic t) {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Missing info', 'Please enter a plant name',
          backgroundColor: const Color(0xFFFFE5E5),
          colorText: const Color(0xFFC1121F),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final interval = int.tryParse(_intervalCtrl.text.trim());
    if (interval == null || interval <= 0) {
      Get.snackbar('Invalid interval', 'Please enter a valid number of days',
          backgroundColor: const Color(0xFFFFE5E5),
          colorText: const Color(0xFFC1121F),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.find<PlantController>().addPlant(
      name: _nameCtrl.text.trim(),
      nickname: _nicknameCtrl.text.trim().isEmpty
          ? _nameCtrl.text.trim()
          : _nicknameCtrl.text.trim(),
      emoji: _selectedEmoji,
      room: _roomCtrl.text.trim().isEmpty ? 'Unknown' : _roomCtrl.text.trim(),
      light: _selectedLight,
      waterIntervalDays: interval,
      photoPath: _photo?.path,
    );
    Get.back();
    Get.snackbar('🌱 Plant added!', '${_nameCtrl.text.trim()} is now in your garden',
        backgroundColor: t.accent, colorText: t.primary,
        snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    final t = SettingsController.to.theme;

    return Scaffold(
      backgroundColor: t.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: t.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 4,
                left: 4,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Text('Add a Plant 🌱',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Photo
                GestureDetector(
                  onTap: () => _showPhotoSheet(t),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _photo != null ? t.primary : t.border,
                          width: _photo != null ? 2 : 1,
                        ),
                      ),
                      child: _photo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(23),
                              child: Image.file(_photo!, fit: BoxFit.cover))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_rounded,
                                    color: t.primaryLight, size: 32),
                                const SizedBox(height: 6),
                                Text('Add Photo',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: t.primaryLight,
                                        fontWeight: FontWeight.bold)),
                                Text('Optional',
                                    style: TextStyle(
                                        fontSize: 11, color: t.textMuted)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Emoji picker
                _Label('Choose an icon', t),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: emojis.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final isSelected = emojis[i] == _selectedEmoji;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedEmoji = emojis[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: isSelected ? t.accent : t.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? t.primary : t.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                              child: Text(emojis[i],
                                  style: const TextStyle(fontSize: 24))),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                _Label('Plant name *', t),
                _Input(controller: _nameCtrl, hint: 'e.g. Monstera', t: t),
                const SizedBox(height: 14),

                _Label('Nickname', t),
                _Input(controller: _nicknameCtrl, hint: 'e.g. Big Guy', t: t),
                const SizedBox(height: 14),

                _Label('Room', t),
                _Input(controller: _roomCtrl, hint: 'e.g. Living Room', t: t),
                const SizedBox(height: 14),

                _Label('Light requirement', t),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: lightOptions.map((opt) {
                    final isSelected = opt == _selectedLight;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLight = opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? t.primary : t.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected ? t.primary : t.border),
                        ),
                        child: Text(opt,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? Colors.white : t.primaryLight,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                _Label('Water every (days) *', t),
                _Input(controller: _intervalCtrl, hint: 'e.g. 7', t: t,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submit(t),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Add to Garden',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final dynamic t;
  const _Label(this.text, this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: t.textMuted,
                letterSpacing: 0.3)),
      );
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final dynamic t;
  final TextInputType keyboardType;
  const _Input({required this.controller, required this.hint, required this.t,
      this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15, color: t.textDark, fontFamily: 'Georgia'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: t.textMuted, fontSize: 14),
          filled: true,
          fillColor: t.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: t.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: t.primary, width: 1.5),
          ),
        ),
      );
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic t;
  final VoidCallback onTap;
  final Color? color;
  const _SheetOption({required this.icon, required this.label, required this.t,
      required this.onTap, this.color});

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
              Icon(icon, color: color ?? t.primary, size: 22),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      color: color ?? t.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
