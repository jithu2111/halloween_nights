import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_fonts.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class GhostHuntScreen extends StatefulWidget {
  const GhostHuntScreen({super.key});

  @override
  State<GhostHuntScreen> createState() => _GhostHuntScreenState();
}

class _GhostHuntScreenState extends State<GhostHuntScreen>
    with TickerProviderStateMixin {
  int score = 0;
  int timeLeft = 30;
  bool gameStarted = false;
  bool gameOver = false;
  List<Creature> creatures = [];
  Timer? gameTimer;
  Timer? creatureSpawner;
  Timer? creatureUpdater;
  late AnimationController _backgroundController;
  AudioPlayer? _backgroundMusicPlayer;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    creatureSpawner?.cancel();
    creatureUpdater?.cancel();
    _backgroundController.dispose();
    _stopBackgroundMusic();
    super.dispose();
  }

  void _startBackgroundMusic() async {
    try {
      _backgroundMusicPlayer = AudioPlayer();
      await _backgroundMusicPlayer!.play(AssetSource('sounds/halloween-background-music-405067.mp3'));
      await _backgroundMusicPlayer!.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Background music failed: $e');
    }
  }

  void _stopBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer?.stop();
      await _backgroundMusicPlayer?.dispose();
      _backgroundMusicPlayer = null;
    } catch (e) {
      print('Stop background music failed: $e');
    }
  }

  void startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      score = 0;
      timeLeft = 30;
      creatures.clear();
    });

    // Start background music
    _startBackgroundMusic();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          endGame();
        }
      });
    });

    creatureSpawner = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted || !gameStarted || gameOver) {
        timer.cancel();
        return;
      }
      spawnCreature();
    });

    creatureUpdater = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !gameStarted || gameOver) {
        timer.cancel();
        return;
      }
      
      setState(() {
        creatures.removeWhere((creature) {
          creature.update();
          return creature.shouldRemove();
        });
      });
    });
  }

  void spawnCreature() {
    final random = Random();
    
    // Reduce trap frequency - 15% chance of trap, 85% chance of other creatures
    CreatureType creatureType;
    if (random.nextDouble() < 0.15) {
      creatureType = CreatureType.trap;
    } else {
      // Select from non-trap creatures
      final nonTrapTypes = CreatureType.values.where((type) => type != CreatureType.trap).toList();
      creatureType = nonTrapTypes[random.nextInt(nonTrapTypes.length)];
    }
    
    final creature = Creature(
      x: random.nextDouble() * (MediaQuery.of(context).size.width - 60),
      y: random.nextDouble() * (MediaQuery.of(context).size.height - 200) + 100,
      type: creatureType,
    );
    setState(() {
      creatures.add(creature);
    });
  }

  void catchCreature(Creature creature) {
    setState(() {
      creatures.remove(creature);
      switch (creature.type) {
        case CreatureType.ghost:
          score += 10;
          break;
        case CreatureType.bat:
          score += 15;
          break;
        case CreatureType.pumpkin:
          score += 25;
          break;
        case CreatureType.spider:
          score += 30;
          break;
        case CreatureType.cat:
          score += 20;
          break;
        case CreatureType.skull:
          score += 40;
          break;
        case CreatureType.witch:
          score -= 15;
          break;
        case CreatureType.trap:
          _triggerTrap();
          break;
      }
    });
  }

  void _triggerTrap() async {
    // Create dramatic jump scare effect with custom sound and haptics
    
    // Immediate heavy impact
    HapticFeedback.heavyImpact();
    
    // Play custom jumpscare sound
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/jumpscare-94984.mp3'));
    } catch (e) {
      print('Audio playback failed: $e');
      // Fallback to system sound if custom audio fails
      SystemSound.play(SystemSoundType.alert);
    }
    
    // Enhanced haptic sequence
    _enhancedHapticFeedback();
    
    _showTrapDialog();
  }

  void _enhancedHapticFeedback() async {
    await Future.delayed(Duration(milliseconds: 50));
    HapticFeedback.vibrate();
    await Future.delayed(Duration(milliseconds: 80));
    HapticFeedback.heavyImpact();
    await Future.delayed(Duration(milliseconds: 50));
    HapticFeedback.vibrate();
    await Future.delayed(Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
    await Future.delayed(Duration(milliseconds: 50));
    HapticFeedback.vibrate();
  }

  void _showTrapDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TrapJumpScareDialog();
      },
    );
    
    Timer(Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void endGame() {
    setState(() {
      gameOver = true;
      gameStarted = false;
    });
    gameTimer?.cancel();
    creatureSpawner?.cancel();
    _stopBackgroundMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ghost Hunt',
          style: AppFonts.creepster(fontSize: 24),
        ),
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A0A2E),
              const Color(0xFF16213E).withOpacity(0.8),
              const Color(0xFF0F3460),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildFog(),
            if (!gameStarted && !gameOver) _buildStartScreen(),
            if (gameStarted) _buildGameScreen(),
            if (gameOver) _buildGameOverScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildFog() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return CustomPaint(
          painter: FogPainter(_backgroundController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '👻',
            style: const TextStyle(fontSize: 100),
          ),
          const SizedBox(height: 20),
          Text(
            'Ghost Hunt',
            style: AppFonts.creepster(
              fontSize: 36,
              color: const Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Catch the creatures before time runs out!\n\n'
            '👻 Ghost: 10 points\n'
            '🦇 Bat: 15 points\n'
            '🎃 Pumpkin: 25 points\n'
            '🕷️ Spider: 30 points\n'
            '🐱 Black Cat: 20 points\n'
            '💀 Skull: 40 points\n'
            '🧙‍♀️ Witch: -15 points',
            style: AppFonts.roboto(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: Text(
              'Start Hunt',
              style: AppFonts.creepster(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Stack(
      children: [
        _buildGameHUD(),
        ...creatures.map((creature) => CreatureWidget(
              creature: creature,
              onTap: () => catchCreature(creature),
            )),
      ],
    );
  }

  Widget _buildGameHUD() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000).withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Score: $score',
              style: AppFonts.creepster(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000).withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Time: $timeLeft',
              style: AppFonts.creepster(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF8B0000).withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF6B35), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Game Over!',
              style: AppFonts.creepster(
                fontSize: 32,
                color: const Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '💀',
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: $score',
              style: AppFonts.creepster(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: startGame,
                  child: Text(
                    'Play Again',
                    style: AppFonts.creepster(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _stopBackgroundMusic();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                  ),
                  child: Text(
                    'Back Home',
                    style: AppFonts.creepster(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum CreatureType { ghost, bat, pumpkin, spider, cat, skull, witch, trap }

class Creature {
  double x;
  double y;
  final CreatureType type;
  late double speed;
  late double dx;
  late double dy;
  double life = 3.0;
  int _directionChanges = 0;

  Creature({required this.x, required this.y, required this.type}) {
    final random = Random();
    switch (type) {
      case CreatureType.ghost:
        speed = 1.0 + random.nextDouble() * 2.0;
        break;
      case CreatureType.bat:
        speed = 3.0 + random.nextDouble() * 3.0;
        break;
      case CreatureType.pumpkin:
        speed = 0.5 + random.nextDouble() * 1.0;
        break;
      case CreatureType.spider:
        speed = 1.5 + random.nextDouble() * 2.5;
        break;
      case CreatureType.cat:
        speed = 2.0 + random.nextDouble() * 2.0;
        break;
      case CreatureType.skull:
        speed = 0.8 + random.nextDouble() * 1.5;
        break;
      case CreatureType.witch:
        speed = 2.5 + random.nextDouble() * 2.0;
        break;
      case CreatureType.trap:
        speed = 1.0 + random.nextDouble() * 1.5;
        break;
    }
    
    double angle = random.nextDouble() * 2 * pi;
    dx = cos(angle) * speed;
    dy = sin(angle) * speed;
  }

  void update() {
    final random = Random();
    
    // Special movement for black cat - unpredictable direction changes
    if (type == CreatureType.cat && random.nextDouble() < 0.05) {
      double angle = random.nextDouble() * 2 * pi;
      dx = cos(angle) * speed;
      dy = sin(angle) * speed;
    }
    
    x += dx;
    y += dy;
    life -= 0.02;

    if (x < 0 || x > 400) {
      dx = -dx;
      _directionChanges++;
    }
    if (y < 100 || y > 700) {
      dy = -dy;
      _directionChanges++;
    }

    x = x.clamp(0, 400);
    y = y.clamp(100, 700);
  }

  bool shouldRemove() {
    return life <= 0;
  }

  String get emoji {
    switch (type) {
      case CreatureType.ghost:
        return '👻';
      case CreatureType.bat:
        return '🦇';
      case CreatureType.pumpkin:
        return '🎃';
      case CreatureType.spider:
        return '🕷️';
      case CreatureType.cat:
        return '🐱';
      case CreatureType.skull:
        return '💀';
      case CreatureType.witch:
        return '🧙‍♀️';
      case CreatureType.trap:
        return '⚡';
    }
  }
}

class CreatureWidget extends StatefulWidget {
  final Creature creature;
  final VoidCallback onTap;

  const CreatureWidget({
    super.key,
    required this.creature,
    required this.onTap,
  });

  @override
  State<CreatureWidget> createState() => _CreatureWidgetState();
}

class _CreatureWidgetState extends State<CreatureWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Special animation for traps - faster, more ominous
    final duration = widget.creature.type == CreatureType.trap 
        ? const Duration(milliseconds: 300) 
        : const Duration(milliseconds: 500);
    
    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );
    
    final scaleTween = widget.creature.type == CreatureType.trap
        ? Tween<double>(begin: 0.6, end: 1.4)  // More dramatic scaling for traps
        : Tween<double>(begin: 0.8, end: 1.2);
    
    _scaleAnimation = scaleTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.creature.x,
      top: widget.creature.y,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: widget.creature.life / 3.0,
                child: Text(
                  widget.creature.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FogPainter extends CustomPainter {
  final double animationValue;

  FogPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (sin(animationValue * 1.5 * pi + i) + 1) / 2;
      final radius = 20 + random.nextDouble() * 40;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.grey.withOpacity(opacity * 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class TrapJumpScareDialog extends StatefulWidget {
  @override
  State<TrapJumpScareDialog> createState() => _TrapJumpScareDialogState();
}

class _TrapJumpScareDialogState extends State<TrapJumpScareDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.1, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _shakeAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );

    _controller.forward();
    
    // Add a shake effect during the animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.asset(
                          'assets/images/scary_image.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Text(
                            'TRAP ACTIVATED!',
                            style: AppFonts.creepster(
                              fontSize: 28,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'You fell into a spooky trap!',
                            style: AppFonts.roboto(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}