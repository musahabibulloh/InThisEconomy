import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Pose enumeration for Ite mascot — maps to SVG assets.
enum ItePose {
  greet,     // Melambaikan tangan — sambutan
  thinking,  // Tangan di dagu — loading/proses
  celebrate, // Tangan ke atas, mata bintang — hasil bagus
  support,   // Gesture suportif — hasil kurang bagus
  chat,      // Memegang clipboard — chatbot
  camera,    // Memegang kamera — foto produk
  idea,      // Memegang lampu — cek ide
  market,    // Kaca pembesar — celah pasar
  hide,      // Menutup mata — password
  dashboard, // Papan data — dashboard
  money,     // Memegang koin — modal
}

/// Reusable Ite mascot avatar widget.
///
/// Renders the correct SVG for the given [pose] at the given [size].
/// Optionally adds a subtle entrance animation.
class IteAvatar extends StatelessWidget {
  final ItePose pose;
  final double size;
  final bool showEntrance;

  const IteAvatar({
    super.key,
    this.pose = ItePose.greet,
    this.size = 48,
    this.showEntrance = true,
  });

  String get _assetPath {
    switch (pose) {
      case ItePose.greet:
        return 'assets/icons/ite_greet.svg';
      case ItePose.thinking:
        return 'assets/icons/ite_thinking.svg';
      case ItePose.celebrate:
        return 'assets/icons/ite_celebrate.svg';
      case ItePose.support:
        return 'assets/icons/ite_support.svg';
      case ItePose.chat:
        return 'assets/icons/ite_chat.svg';
      case ItePose.camera:
        return 'assets/icons/ite_camera.svg';
      case ItePose.idea:
        return 'assets/icons/ite_idea.svg';
      case ItePose.market:
        return 'assets/icons/ite_market.svg';
      case ItePose.hide:
        return 'assets/icons/ite_hide.svg';
      case ItePose.dashboard:
        return 'assets/icons/ite_dashboard.svg';
      case ItePose.money:
        return 'assets/icons/ite_money.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
    );

    if (showEntrance) {
      avatar = avatar
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 400.ms,
            curve: Curves.easeOutBack,
          );
    }

    return SizedBox(
      width: size,
      height: size,
      child: avatar,
    );
  }
}
