import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customize your garden experience',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Profile ─────────────────────────────────────────────
                  _SectionTitle('👤 Profile', t),
                  _SettingsCard(t: t, children: [
                    _NameTile(s: s, t: t),
                  ]),
                  const SizedBox(height: 20),

                  // ── Appearance ──────────────────────────────────────────
                  _SectionTitle('🎨 Appearance', t),
                  _ThemePicker(s: s),
                  const SizedBox(height: 20),

                  // ── Reminders ───────────────────────────────────────────
                  _SectionTitle('🔔 Reminders', t),
                  _SettingsCard(t: t, children: [
                    _NotifTimeTile(s: s, t: t),
                    _Divider(t),
                    _ToggleTile(
                      t: t,
                      icon: '📳',
                      label: 'Haptic Feedback',
                      subtitle: 'Vibrate when watering a plant',
                      value: s.hapticsEnabled.value,
                      onChanged: s.setHaptics,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Display ─────────────────────────────────────────────
                  _SectionTitle('📋 Display', t),
                  _SettingsCard(t: t, children: [
                    _SortTile(s: s, t: t),
                    _Divider(t),
                    _WeekStartTile(s: s, t: t),
                    _Divider(t),
                    _ToggleTile(
                      t: t,
                      icon: '🏆',
                      label: 'Show Streak',
                      subtitle: 'Display watering streak in stats',
                      value: s.showStreak.value,
                      onChanged: s.setShowStreak,
                    ),
                    _Divider(t),
                    _WaterUnitTile(s: s, t: t),
                  ]),
                  const SizedBox(height: 20),

                  // ── About ───────────────────────────────────────────────
                  _SectionTitle('ℹ️ About', t),
                  _SettingsCard(t: t, children: [
                    _InfoTile(
                      t: t,
                      icon: '🌱',
                      label: 'Version',
                      value: '1.0.0',
                    ),
                    _Divider(t),
                    _InfoTile(
                      t: t,
                      icon: '💧',
                      label: 'Total plants tracked',
                      value: 'Stored locally',
                    ),
                    _Divider(t),
                    _ActionTile(
                      t: t,
                      icon: '🗑',
                      label: 'Reset All Data',
                      color: Colors.redAccent,
                      onTap: () => _confirmReset(t),
                    ),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _confirmReset(PlantThemeData t) {
    Get.dialog(AlertDialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Reset all data?',
          style: TextStyle(color: t.textDark, fontWeight: FontWeight.bold)),
      content: Text('This will remove all plants and settings.',
          style: TextStyle(color: t.textMuted)),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel', style: TextStyle(color: t.textMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.snackbar('🗑 Reset', 'All data has been cleared',
                backgroundColor: const Color(0xFFFFE5E5),
                colorText: const Color(0xFFC1121F),
                snackPosition: SnackPosition.BOTTOM);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Reset', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final PlantThemeData t;
  const _SectionTitle(this.text, this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: t.textMuted,
                letterSpacing: 0.5)),
      );
}

// ── Card wrapper ──────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final PlantThemeData t;
  final List<Widget> children;
  const _SettingsCard({required this.t, required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: t.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(t.isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      );
}

class _Divider extends StatelessWidget {
  final PlantThemeData t;
  const _Divider(this.t);
  @override
  Widget build(BuildContext context) => Divider(
      height: 1, color: t.border, indent: 16, endIndent: 16);
}

// ── Name tile ─────────────────────────────────────────────────────────────────

class _NameTile extends StatelessWidget {
  final SettingsController s;
  final PlantThemeData t;
  const _NameTile({required this.s, required this.t});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('🌿', style: const TextStyle(fontSize: 22)),
      title: Text('Your Name',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: t.textDark, fontSize: 15)),
      subtitle: Text(
        s.userName.value.isEmpty ? 'Tap to set your name' : s.userName.value,
        style: TextStyle(color: t.textMuted, fontSize: 13),
      ),
      trailing: Icon(Icons.chevron_right, color: t.textMuted, size: 20),
      onTap: () => _showNameDialog(s, t),
    );
  }

  void _showNameDialog(SettingsController s, PlantThemeData t) {
    final ctrl = TextEditingController(text: s.userName.value);
    Get.dialog(
      AlertDialog(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Your name',
            style: TextStyle(
                color: t.textDark, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: t.textDark),
          decoration: InputDecoration(
            hintText: 'e.g. Alex',
            hintStyle: TextStyle(color: t.textMuted),
            filled: true,
            fillColor: t.accent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: t.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              s.setUserName(ctrl.text);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: t.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Theme picker ──────────────────────────────────────────────────────────────

class _ThemePicker extends StatelessWidget {
  final SettingsController s;
  const _ThemePicker({required this.s});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppThemes.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final theme = AppThemes.all[i];
          final isSelected = s.themeIndex.value == i;
          return GestureDetector(
            onTap: () => s.setTheme(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: theme.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: theme.primary.withOpacity(0.5),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  Text(theme.emoji,
                      style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(
                    theme.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Notification time tile ────────────────────────────────────────────────────

class _NotifTimeTile extends StatelessWidget {
  final SettingsController s;
  final PlantThemeData t;
  const _NotifTimeTile({required this.s, required this.t});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Text('⏰', style: TextStyle(fontSize: 22)),
        title: Text('Reminder Time',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: t.textDark,
                fontSize: 15)),
        subtitle: Text(s.notifTimeLabel,
            style: TextStyle(color: t.textMuted, fontSize: 13)),
        trailing: Icon(Icons.chevron_right, color: t.textMuted, size: 20),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime:
                TimeOfDay(hour: s.notifHour.value, minute: s.notifMin.value),
            builder: (ctx, child) => Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(primary: t.primary),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            s.setNotifTime(picked.hour, picked.minute);
          }
        },
      );
}

// ── Sort order tile ───────────────────────────────────────────────────────────

class _SortTile extends StatelessWidget {
  final SettingsController s;
  final PlantThemeData t;
  const _SortTile({required this.s, required this.t});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Text('🔃', style: TextStyle(fontSize: 22)),
        title: Text('Sort Plants By',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: t.textDark,
                fontSize: 15)),
        subtitle: Text(s.sortOrderLabel,
            style: TextStyle(color: t.textMuted, fontSize: 13)),
        trailing: Icon(Icons.chevron_right, color: t.textMuted, size: 20),
        onTap: () => Get.bottomSheet(_SortSheet(s: s, t: t)),
      );
}

class _SortSheet extends StatelessWidget {
  final SettingsController s;
  final PlantThemeData t;
  const _SortSheet({required this.s, required this.t});

  @override
  Widget build(BuildContext context) => Container(
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
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: t.border, borderRadius: BorderRadius.circular(2)),
            ),
            Text('Sort Plants By',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: t.textDark)),
            const SizedBox(height: 12),
            ...SortOrder.values.map((order) {
              final labels = {
                SortOrder.urgency: ('🚨', 'Most Urgent First'),
                SortOrder.name: ('🔤', 'Name (A–Z)'),
                SortOrder.room: ('🏠', 'By Room'),
                SortOrder.dateAdded: ('📅', 'Date Added'),
              };
              final (emoji, label) = labels[order]!;
              final isSelected = s.sortOrder.value == order;
              return GestureDetector(
                onTap: () {
                  s.setSortOrder(order);
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? t.accent : t.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? t.primary : t.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(emoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Text(label,
                          style: TextStyle(
                              color: isSelected ? t.primary : t.textDark,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 15)),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check, color: t.primary, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
}

// ── Week start tile ───────────────────────────────────────────────────────────

class _WeekStartTile extends StatelessWidget {
  final SettingsController s;
  final PlantThemeData t;
  const _WeekStartTile({required this.s, required this.t});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Text('📅', style: TextStyle(fontSize: 22)),
        title: Text('Week Starts On',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: t.textDark,
                fontSize: 15)),
        subtitle: Text(
            s.weekStartMonday.value ? 'Monday' : 'Sunday',
            style: TextStyle(color: t.textMuted, fontSize: 13)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MiniToggle(
              label: 'Mon',
              selected: s.weekStartMonday.value,
              t: t,
              onTap: () => s.setWeekStartMonday(true),
            ),
            const SizedBox(width: 6),
            _MiniToggle(
              label: 'Sun',
              selected: !s.weekStartMonday.value,
              t: t,
              onTap: () => s.setWeekStartMonday(false),
            ),
          ],
        ),
      );
}

class _MiniToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final PlantThemeData t;
  final VoidCallback onTap;
  const _MiniToggle(
      {required this.label,
      required this.selected,
      required this.t,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? t.primary : t.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : t.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}

// ── Water unit tile ───────────────────────────────────────────────────────────

class _WaterUnitTile extends StatelessWidget {
  final SettingsController s;
  final PlantThemeData t;
  const _WaterUnitTile({required this.s, required this.t});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Text('💧', style: TextStyle(fontSize: 22)),
        title: Text('Water Amount Unit',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: t.textDark,
                fontSize: 15)),
        subtitle: Text(s.waterUnitLabel,
            style: TextStyle(color: t.textMuted, fontSize: 13)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: WaterUnit.values.map((unit) {
            final labels = {
              WaterUnit.none: '—',
              WaterUnit.ml: 'ml',
              WaterUnit.oz: 'oz',
            };
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: _MiniToggle(
                label: labels[unit]!,
                selected: s.waterUnit.value == unit,
                t: t,
                onTap: () => s.setWaterUnit(unit),
              ),
            );
          }).toList(),
        ),
      );
}

// ── Toggle tile ───────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final PlantThemeData t;
  final String icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.t,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 22)),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: t.textDark,
                fontSize: 15)),
        subtitle: Text(subtitle,
            style: TextStyle(color: t.textMuted, fontSize: 13)),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: t.primary,
        ),
      );
}

// ── Info tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final PlantThemeData t;
  final String icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.t,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 22)),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: t.textDark,
                fontSize: 15)),
        trailing: Text(value,
            style: TextStyle(color: t.textMuted, fontSize: 13)),
      );
}

// ── Action tile ───────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final PlantThemeData t;
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.t,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 22)),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 15)),
        trailing: Icon(Icons.chevron_right, color: color, size: 20),
        onTap: onTap,
      );
}
