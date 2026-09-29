import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'features/pharmacy/presentation/screens/pharmacy_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VitalLinkApp()));
}

class VitalLinkApp extends StatelessWidget {
  const VitalLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitalLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.tealPrimary,
          primary: AppColors.tealPrimary,
        ),
        useMaterial3: true,
      ),
      home: const PharmacyListScreen(),
    );
  }
}
