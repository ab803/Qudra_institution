import 'package:flutter/material.dart';

class InstitutionSplashLogo extends StatelessWidget {
  final Animation<double> scale;
  final Animation<double> opacity;

  const InstitutionSplashLogo({
    super.key,
    required this.scale,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [

        // This block renders the institution splash logo with scale and fade animations.
        ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: Image.asset(
              'assets/images/Qudra_Institution_logo.png',
              width: 190,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}