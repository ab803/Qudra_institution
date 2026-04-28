import 'package:flutter/material.dart';

class InstitutionSplashAnimations {
  // This animation scales the institution logo in with a soft pop effect.
  late Animation<double> logoScale;

  // This animation fades the institution logo into view.
  late Animation<double> logoOpacity;

  // This animation slides the splash tagline upward into view.
  late Animation<Offset> textSlide;

  // This animation fades the splash tagline into view.
  late Animation<double> textOpacity;

  InstitutionSplashAnimations({
    required AnimationController logoController,
    required AnimationController textController,
  }) {
    logoScale = Tween<double>(begin: 0.65, end: 1).animate(
      CurvedAnimation(
        parent: logoController,
        curve: Curves.easeOutBack,
      ),
    );

    logoOpacity = Tween<double>(begin: 0, end: 1).animate(logoController);

    textSlide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: textController,
        curve: Curves.easeOut,
      ),
    );

    textOpacity = Tween<double>(begin: 0, end: 1).animate(textController);
  }
}