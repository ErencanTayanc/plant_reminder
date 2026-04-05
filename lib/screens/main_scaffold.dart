import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/plant_controller.dart';
import '../controllers/settings_controller.dart';
import 'home_screen.dart';
import 'reminders_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  static const _screens = [
    HomeScreen(),
    RemindersScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PlantController>();
    final s = SettingsController.to;

    return Obx(() {
      final t = s.theme;

      return Scaffold(
        backgroundColor: t.bg,
        body: IndexedStack(
          index: ctrl.currentTab.value,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(top: BorderSide(color: t.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(t.isDark ? 0.4 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 62,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: '🌿',
                    label: 'Plants',
                    index: 0,
                    currentIndex: ctrl.currentTab.value,
                    onTap: () => ctrl.changeTab(0),
                    t: t,
                  ),
                  _NavItem(
                    icon: '🔔',
                    label: 'Reminders',
                    index: 1,
                    currentIndex: ctrl.currentTab.value,
                    onTap: () => ctrl.changeTab(1),
                    t: t,
                  ),
                  _NavItem(
                    icon: '📊',
                    label: 'Stats',
                    index: 2,
                    currentIndex: ctrl.currentTab.value,
                    onTap: () => ctrl.changeTab(2),
                    t: t,
                  ),
                  _NavItem(
                    icon: '⚙️',
                    label: 'Settings',
                    index: 3,
                    currentIndex: ctrl.currentTab.value,
                    onTap: () => ctrl.changeTab(3),
                    t: t,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  final dynamic t;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? t.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 21)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? t.primary : t.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
