import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/plant_controller.dart';
import '../controllers/settings_controller.dart';
import 'home_screen.dart';
import 'reminders_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        floatingActionButton: FloatingActionButton(
          mini: true,
          onPressed: () {
            // Add your action here
          },
          child: SvgPicture.asset(
            'assets/svg/gemini.svg',
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(
              t.bg,
              BlendMode.srcIn,
            ), // Change color
          ),
        ),
        body: IndexedStack(index: ctrl.currentTab.value, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(top: BorderSide(color: t.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(t.isDark ? 0.35 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.eco_outlined,
                    activeIcon: Icons.eco,
                    label: 'nav_plants'.tr,
                    index: 0,
                    currentIndex: ctrl.currentTab.value,
                    onTap: () => ctrl.changeTab(0),
                    t: t,
                  ),
                  _NavItem(
                    icon: Icons.notifications_none_rounded,
                    activeIcon: Icons.notifications_active_rounded,
                    label: 'nav_reminders'.tr,
                    index: 1,
                    currentIndex: ctrl.currentTab.value,
                    onTap: () => ctrl.changeTab(1),
                    t: t,
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart,
                    label: 'nav_stats'.tr,
                    index: 2,
                    currentIndex: ctrl.currentTab.value,
                    onTap: () => ctrl.changeTab(2),
                    t: t,
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'nav_settings'.tr,
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
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  final dynamic t;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? t.accent.withOpacity(0.4) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 24,
                color: isActive ? t.primary : t.textMuted,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? t.primary : t.textMuted,
              ),
            ),

            const SizedBox(height: 4),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isActive ? 16 : 0,
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
