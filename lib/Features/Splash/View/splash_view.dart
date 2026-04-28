import 'package:flutter/material.dart';
import '../widgets/InstitutionLoader.dart';
import '../widgets/InstitutionSplashLogo.dart';
import '../widgets/InstitutionTagline.dart';
import '../widgets/institution_splash_controller.dart';

class InstitutionSplashView extends StatefulWidget {
  const InstitutionSplashView({super.key});

  @override
  State<InstitutionSplashView> createState() => _InstitutionSplashViewState();
}

class _InstitutionSplashViewState extends State<InstitutionSplashView>
    with TickerProviderStateMixin {
  // This controller manages splash animations and route navigation.
  late InstitutionSplashController controller;

  @override
  void initState() {
    super.initState();
    controller = InstitutionSplashController(vsync: this, context: context);
    controller.init();
  }

  @override
  void dispose() {
    // This block disposes all splash animation resources safely.
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.scaffoldBackgroundColor,
              theme.cardColor,
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InstitutionSplashLogo(
              scale: controller.logoScale,
              opacity: controller.logoOpacity,
            ),
            const SizedBox(height: 34),
            InstitutionTagline(
              slide: controller.textSlide,
              opacity: controller.textOpacity,
            ),
            const SizedBox(height: 44),
            InstitutionLoader(controller: controller.dotsController),
          ],
        ),
      ),
    );
  }
}
