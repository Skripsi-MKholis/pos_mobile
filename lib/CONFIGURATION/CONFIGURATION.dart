import 'package:flutter/material.dart';

class Warna {
  static const Color Primary = Color(0xFFAD8764);
  static const Color Secondary = Color(0xFFD0A175);
  static const Color Tertiary = Color(0xFF5D6D7E);
  static const Color Neutral = Color(0xFFF4EFEA);

  static const Color Black = Color(0xFF222222);
  static const Color TextBold = Color(0xFF222222);
  static const Color BG = Color(0xffF8FAFC);
  static const Color Line = Color(0xFFBDC9D5);

  // Dark mode
  static const Color DarkBG = Color(0xff141414);
  static const Color DarkSecondary = Color(0xffE2E8F0);
  static const Color DarkLine = Color(0xFF334155);
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}

/* Efek Pop */

class PopController {
  void Function()? _triggerPop;

  void _register(void Function() callback) {
    _triggerPop = callback;
  }

  void pop() {
    _triggerPop?.call();
  }
}

class PopEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scale;
  final PopController? controller;

  const PopEffect({
    required this.child,
    this.duration = const Duration(milliseconds: 150),
    this.scale = 0.9,
    this.controller,
  });

  @override
  State<PopEffect> createState() => _PopEffectState();
}

class _PopEffectState extends State<PopEffect>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    widget.controller?._register(_runPop);
  }

  void _runPop() async {
    setState(() => _scale = widget.scale);
    await Future.delayed(widget.duration);
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: widget.duration,
      child: widget.child,
    );
  }
}

/* Efek Pop */
