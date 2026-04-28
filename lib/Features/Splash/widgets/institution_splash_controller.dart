import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'InstitutionSplashAnimations.dart';

class InstitutionSplashController {
  // This provider supplies ticker callbacks for splash animations.
  final TickerProvider vsync;

  // This context is used to navigate away from the splash screen.
  final BuildContext context;

  // This controller animates the institution logo.
  late AnimationController logoController;

  // This controller animates the institution tagline.
  late AnimationController textController;

  // This controller animates the splash loading dots.
  late AnimationController dotsController;

  // This object stores all derived institution splash animations.
  late InstitutionSplashAnimations animations;

  // This timer delays the splash exit until animations are shown.
  Timer? _navigationTimer;

  InstitutionSplashController({required this.vsync, required this.context});

  void init() {
    logoController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    );

    textController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    );

    dotsController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    animations = InstitutionSplashAnimations(
      logoController: logoController,
      textController: textController,
    );

    startAnimation();
    navigateNext();
  }

  // This method starts the splash logo and text animations sequentially.
  void startAnimation() {
    logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (textController.isDismissed) {
        textController.forward();
      }
    });
  }

  // This method routes authenticated institutions to the dashboard and guests to login.
  void navigateNext() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!context.mounted) return;

      final hasSession = Supabase.instance.client.auth.currentUser != null;
      context.go(hasSession ? '/Dashboard' : '/institutionLogin');
    });
  }

  Animation<double> get logoScale => animations.logoScale;
  Animation<double> get logoOpacity => animations.logoOpacity;
  Animation<Offset> get textSlide => animations.textSlide;
  Animation<double> get textOpacity => animations.textOpacity;

  // This method disposes the splash timer and all animation controllers.
  void dispose() {
    _navigationTimer?.cancel();
    logoController.dispose();
    textController.dispose();
    dotsController.dispose();
  }
}