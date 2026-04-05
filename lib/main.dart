import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/plant_controller.dart';
import 'controllers/settings_controller.dart';
import 'screens/main_scaffold.dart';
import 'screens/plant_detail_screen.dart';
import 'screens/add_plant_screen.dart';

void main() {
  runApp(const PlantApp());
}

class PlantApp extends StatelessWidget {
  const PlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Plant Watering',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      initialBinding: BindingsBuilder(() {
        Get.put(SettingsController());
        Get.put(PlantController());
      }),
      getPages: [
        GetPage(name: '/', page: () => const MainScaffold()),
        GetPage(
          name: '/plant/:id',
          page: () => const PlantDetailScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/add',
          page: () => const AddPlantScreen(),
          transition: Transition.downToUp,
        ),
      ],
      // Dynamically rebuild theme when settings change
      builder: (context, child) {
        return Obx(() {
          final t = SettingsController.to.theme;
          return Theme(
            data: t.materialTheme,
            child: child!,
          );
        });
      },
    );
  }
}
