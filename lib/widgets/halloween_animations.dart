import 'package:flutter/material.dart';
import 'dart:math';

class FloatingGhosts extends StatefulWidget {
  final int ghostCount;
  final double speed;

  const FloatingGhosts({
    super.key,
    this.ghostCount = 5,
    this.speed = 1.0,
  });

  @override
  State<FloatingGhosts> createState() => _FloatingGhostsState();
}

class _FloatingGhostsState extends State<FloatingGhosts>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<Ghost> _ghosts;

  @override
  void initState() {
    super.initState();
    _initializeGhosts();
  }

  void _initializeGhosts() {
    final random = Random();
    _controllers = [];
    _animations = [];
    _ghosts = [];

    for (int i = 0; i < widget.ghostCount; i++) {
      final controller = AnimationController(
        duration: Duration(
          milliseconds: (3000 + random.nextInt(2000) * widget.speed).round(),
        ),
        vsync: this,
      );

      final startX = random.nextDouble();
      final endX = random.nextDouble();
      final startY = random.nextDouble();
      final endY = random.nextDouble();

      final animation = Tween<Offset>(
        begin: Offset(startX, startY),
        end: Offset(endX, endY),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));

      final ghost = Ghost(
        opacity: 0.3 + random.nextDouble() * 0.4,
        size: 20 + random.nextDouble() * 30,
        emoji: ['👻', '🎃', '💀'][random.nextInt(3)],
      );

      _controllers.add(controller);
      _animations.add(animation);
      _ghosts.add(ghost);

      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.ghostCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Positioned(
              left: _animations[index].value.dx * MediaQuery.of(context).size.width,
              top: _animations[index].value.dy * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: _ghosts[index].opacity,
                child: Text(
                  _ghosts[index].emoji,
                  style: TextStyle(
                    fontSize: _ghosts[index].size,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class PulsingPumpkin extends StatefulWidget {
  final double size;
  final Color color;

  const PulsingPumpkin({
    super.key,
    this.size = 50,
    this.color = const Color(0xFFFF6B35),
  });

  @override
  State<PulsingPumpkin> createState() => _PulsingPumpkinState();
}

class _PulsingPumpkinState extends State<PulsingPumpkin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              '🎃',
              style: TextStyle(fontSize: widget.size * 0.8),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

class SpiderWeb extends StatefulWidget {
  final double size;

  const SpiderWeb({
    super.key,
    this.size = 200,
  });

  @override
  State<SpiderWeb> createState() => _SpiderWebState();
}

class _SpiderWebState extends State<SpiderWeb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: CustomPaint(
            painter: SpiderWebPainter(),
            size: Size(widget.size, widget.size),
          ),
        );
      },
    );
  }
}

class FallingLeaves extends StatefulWidget {
  final int leafCount;

  const FallingLeaves({
    super.key,
    this.leafCount = 10,
  });

  @override
  State<FallingLeaves> createState() => _FallingLeavesState();
}

class _FallingLeavesState extends State<FallingLeaves>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fallAnimations;
  late List<Animation<double>> _swayAnimations;
  late List<Leaf> _leaves;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _fallAnimations = [];
    _swayAnimations = [];
    _leaves = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllers.isEmpty) {
      _initializeLeaves();
    }
  }

  void _initializeLeaves() {
    final random = Random();
    final screenSize = MediaQuery.of(context).size;

    for (int i = 0; i < widget.leafCount; i++) {
      final controller = AnimationController(
        duration: Duration(
          milliseconds: 2000 + random.nextInt(3000),
        ),
        vsync: this,
      );

      final fallAnimation = Tween<double>(
        begin: -50,
        end: screenSize.height + 50,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));

      final swayAnimation = Tween<double>(
        begin: -20,
        end: 20,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));

      final leaf = Leaf(
        x: random.nextDouble() * screenSize.width,
        emoji: ['🍂', '🍁', '🥀'][random.nextInt(3)],
        size: 20 + random.nextDouble() * 20,
        rotation: random.nextDouble() * 2 * pi,
      );

      _controllers.add(controller);
      _fallAnimations.add(fallAnimation);
      _swayAnimations.add(swayAnimation);
      _leaves.add(leaf);

      controller.repeat();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.leafCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Positioned(
              left: _leaves[index].x + _swayAnimations[index].value,
              top: _fallAnimations[index].value,
              child: Transform.rotate(
                angle: _leaves[index].rotation + _controllers[index].value * 2 * pi,
                child: Text(
                  _leaves[index].emoji,
                  style: TextStyle(
                    fontSize: _leaves[index].size,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class HalloweenParticles extends StatefulWidget {
  final int particleCount;
  final List<String> particles;

  const HalloweenParticles({
    super.key,
    this.particleCount = 15,
    this.particles = const ['⭐', '✨', '💫', '🌟'],
  });

  @override
  State<HalloweenParticles> createState() => _HalloweenParticlesState();
}

class _HalloweenParticlesState extends State<HalloweenParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _positionAnimations;
  late List<Animation<double>> _opacityAnimations;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }

  void _initializeParticles() {
    final random = Random();
    _controllers = [];
    _positionAnimations = [];
    _opacityAnimations = [];
    _particles = [];

    for (int i = 0; i < widget.particleCount; i++) {
      final controller = AnimationController(
        duration: Duration(
          milliseconds: 1000 + random.nextInt(2000),
        ),
        vsync: this,
      );

      final startX = random.nextDouble();
      final startY = random.nextDouble();
      final endX = startX + (random.nextDouble() - 0.5) * 0.4;
      final endY = startY - random.nextDouble() * 0.3;

      final positionAnimation = Tween<Offset>(
        begin: Offset(startX, startY),
        end: Offset(endX.clamp(0.0, 1.0), endY.clamp(0.0, 1.0)),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      final opacityAnimation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: const Interval(0.5, 1.0),
      ));

      final particle = Particle(
        emoji: widget.particles[random.nextInt(widget.particles.length)],
        size: 15 + random.nextDouble() * 20,
      );

      _controllers.add(controller);
      _positionAnimations.add(positionAnimation);
      _opacityAnimations.add(opacityAnimation);
      _particles.add(particle);

      controller.repeat();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.particleCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Positioned(
              left: _positionAnimations[index].value.dx * MediaQuery.of(context).size.width,
              top: _positionAnimations[index].value.dy * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: _opacityAnimations[index].value,
                child: Text(
                  _particles[index].emoji,
                  style: TextStyle(
                    fontSize: _particles[index].size,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class SpiderWebPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw radial lines
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi * 2) / 8;
      final end = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawLine(center, end, paint);
    }

    // Draw concentric circles
    for (int i = 1; i <= 5; i++) {
      final webRadius = (radius / 5) * i;
      canvas.drawCircle(center, webRadius, paint);
    }

    // Draw spider
    final spiderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx + radius * 0.7, center.dy - radius * 0.3),
      5,
      spiderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data classes
class Ghost {
  final double opacity;
  final double size;
  final String emoji;

  Ghost({
    required this.opacity,
    required this.size,
    required this.emoji,
  });
}

class Leaf {
  final double x;
  final String emoji;
  final double size;
  final double rotation;

  Leaf({
    required this.x,
    required this.emoji,
    required this.size,
    required this.rotation,
  });
}

class Particle {
  final String emoji;
  final double size;

  Particle({
    required this.emoji,
    required this.size,
  });
}