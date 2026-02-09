import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CyberGlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double glitchAmount;
  final bool autoPlay;

  const CyberGlitchText(
      this.text, {
        super.key,
        required this.style,
        this.glitchAmount = 3.0,
        this.autoPlay = true,
      });

  @override
  State<CyberGlitchText> createState() => _CyberGlitchTextState();
}

class _CyberGlitchTextState extends State<CyberGlitchText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // ignore: unused_field
  late Animation<double> _randomTrigger;
  Timer? _glitchTimer;
  final Random _random = Random();

  double _cyanOffsetX = 0;
  double _cyanOffsetY = 0;
  double _magentaOffsetX = 0;
  double _magentaOffsetY = 0;

  bool _isGlitching = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );

    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (_controller.status == AnimationStatus.dismissed && _isGlitching) {
        _controller.forward();
        _generateRandomOffsets();
      }
    });

    if (widget.autoPlay) {
      _startRandomGlitchLoop();
    }
  }

  void _generateRandomOffsets() {
    setState(() {
      _cyanOffsetX = (_random.nextDouble() * 2 - 1) * widget.glitchAmount;
      _cyanOffsetY = (_random.nextDouble() * 2 - 1) * widget.glitchAmount;

      _magentaOffsetX = (_random.nextDouble() * 2 - 1) * widget.glitchAmount;
      _magentaOffsetY = (_random.nextDouble() * 2 - 1) * widget.glitchAmount;
    });
  }

  void _resetOffsets() {
    setState(() {
      _cyanOffsetX = 0;
      _cyanOffsetY = 0;
      _magentaOffsetX = 0;
      _magentaOffsetY = 0;
    });
  }

  void _startRandomGlitchLoop() {
    _glitchTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_random.nextDouble() > 0.3) {
        _triggerGlitch();
      }
    });
  }
  void _triggerGlitch() {
    if (!mounted) return;

    setState(() {
      _isGlitching = true;
    });
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isGlitching = false;
        });
        _controller.stop();
        _resetOffsets();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _glitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_isGlitching)
          Transform.translate(
            offset: Offset(_cyanOffsetX, _cyanOffsetY),
            child: Text(
              widget.text,
              style: widget.style.copyWith(
                color: const Color(0xFF00FFFF).withOpacity(0.8),
              ),
            ),
          ),

        if (_isGlitching)
          Transform.translate(
            offset: Offset(_magentaOffsetX, _magentaOffsetY),
            child: Text(
              widget.text,
              style: widget.style.copyWith(
                color: const Color(0xFFFF00FF).withOpacity(0.8),
              ),
            ),
          ),

        Transform.translate(
          offset: _isGlitching ? Offset(_cyanOffsetX / 2, _magentaOffsetY / 2) : Offset.zero,
          child: Text(
            widget.text,
            style: widget.style,
          ),
        ),
      ],
    );
  }
}