import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cake_model.dart';
import '../providers/cart_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';
import 'game_page.dart';


class CatchGameScreen extends StatefulWidget {
  const CatchGameScreen({super.key});

  @override
  State<CatchGameScreen> createState() => _CatchGameScreenState();
}

class _CatchGameScreenState extends State<CatchGameScreen> {
  @override
  Widget build(BuildContext context) {
    return const GamePage();
  }
}

class FallingItem {
  double x; // 0..1 as fraction of width
  double y; // pixels
  double speed; // pixels per tick
  final bool isFood; // true for cake, false for shoe
  final Cake? cake; // null if shoe
  final int shoePoints; // points to subtract if shoe
  final String? asset; // optional asset path for image
  bool caught; // flag to prevent double-trigger

  FallingItem({
    required this.x,
    required this.y,
    required this.speed,
    required this.isFood,
    this.cake,
    this.shoePoints = 5,
    this.asset,
    this.caught = false,
  });
}

class FallingCake {
  double x; // 0..1 as fraction of width
  double y; // pixels
  double speed; // pixels per tick
  final Cake cake;

  FallingCake({
    required this.x,
    required this.y,
    required this.speed,
    required this.cake,
  });
}

class _OldCatchGameScreenState extends State<CatchGameScreen>
    with TickerProviderStateMixin {
  final Random _rand = Random();
  final List<FallingItem> _items = [];
  late final AudioPlayer _bgPlayer;
  late final AudioPlayer _sfxPlayer;
  Timer? _ticker;
  double _basketX = 0.5; // fraction center
  double _basketWidth = 120;
  int _nextId = 10000;
  bool _running = true;
  int _score = 0;
  int _highScore = 0;
  int _rewardsCount = 0;
  bool _gameStarted = false;
  bool _mouthOpen = false;

  // Pou assets (from pou-main folder)
  final List<String> _foodAssets = [
    'pou-main/food_drop/food/apple_juice.png',
    'pou-main/food_drop/food/bacon.png',
    'pou-main/food_drop/food/banana.png',
    'pou-main/food_drop/food/broccoli.png',
    'pou-main/food_drop/food/burger.png',
    'pou-main/food_drop/food/cabbage.png',
    'pou-main/food_drop/food/candy_cane.png',
    'pou-main/food_drop/food/cheese_cake.png',
    'pou-main/food_drop/food/chicken_leg.png',
    'pou-main/food_drop/food/chili_pepper.png',
    'pou-main/food_drop/food/chocolate_bar.png',
  ];

  final List<String> _trashAssets = [
    'pou-main/food_drop/trash/shoe.png',
    'pou-main/food_drop/trash/horseshoe.png',
    'pou-main/food_drop/trash/plane.png',
    'pou-main/food_drop/trash/pool_ball.png',
    'pou-main/food_drop/trash/cd.png',
  ];

  // Animation controllers for effects
  late AnimationController _scoreController;
  late AnimationController _catchController;
  late AnimationController _eatingController;

  // Pou character does not need Rive controller
  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _catchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _eatingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bgPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    (() async {
      try {
        await _bgPlayer.setReleaseMode(ReleaseMode.loop);
        await _bgPlayer.setVolume(1.0); // Make sure volume is max
      } catch (e) {
        debugPrint('Could not setup background music: $e');
      }
    })();
    (() async {
      try {
        await _sfxPlayer.setVolume(1.0);
      } catch (e) {
        debugPrint('Could not setup SFX player: $e');
      }
    })();
    _loadSaved();
    // Do not start game loop or music until tap
  }

  @override
  void dispose() {
    _ticker?.cancel();
    try {
      _bgPlayer.stop();
      _bgPlayer.dispose();
    } catch (_) {}
    try {
      _sfxPlayer.dispose();
    } catch (_) {}
    // No Rive controller to dispose
    _scoreController.dispose();
    _catchController.dispose();
    _eatingController.dispose();
    super.dispose();
  }

  void _startGameLoop() {
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (t) {
      if (!_running || !_gameStarted) return;
      setState(() {
        // move existing items
        for (var item in _items) {
          item.y += item.speed;
        }

        // remove off-screen
        _items.removeWhere(
          (item) => item.y > MediaQuery.of(context).size.height + 50,
        );

        // random spawn (70% food, 30% shoes)
        if (_rand.nextDouble() < 0.02) {
          if (_rand.nextDouble() < 0.7) {
            _spawnFood();
          } else {
            _spawnShoe();
          }
        }

        _checkCatches();
      });
    });
  }

  void _spawnFood() {
    final cake = Cake(
      id: _nextId++,
      title: 'Cake',
      description: 'Yummy cake',
      image: '',
      price: 5.0 + _rand.nextInt(20),
      rating: 4.5,
      reviews: 10,
      sweetness: 'Medium',
      size: 'Small',
      servings: 1,
    );

    final x = _rand.nextDouble() * 0.9 + 0.05;
    final speed = 2.0 + _rand.nextDouble() * 3.0;
    // pick a random food asset if available
    final asset = _foodAssets[_rand.nextInt(_foodAssets.length)];
    _items.add(
      FallingItem(
        x: x,
        y: -30,
        speed: speed,
        isFood: true,
        cake: cake,
        asset: asset,
      ),
    );
  }

  void _spawnShoe() {
    final x = _rand.nextDouble() * 0.9 + 0.05;
    final speed = 2.5 + _rand.nextDouble() * 2.5; // slightly faster
    final pointsLoss = 3 + _rand.nextInt(5); // lose 3-7 points
    final asset = _trashAssets[_rand.nextInt(_trashAssets.length)];
    _items.add(
      FallingItem(
        x: x,
        y: -30,
        speed: speed,
        isFood: false,
        shoePoints: pointsLoss,
        asset: asset,
      ),
    );
  }

  void _checkCatches() {
    final width = MediaQuery.of(context).size.width;
    final basketCenterX = _basketX * width;
    final basketY = MediaQuery.of(context).size.height - 160;
    final mouthY = basketY - 30; // Position where food enters mouth

    for (int i = _items.length - 1; i >= 0; i--) {
      final item = _items[i];
      final itemX = item.x * width;
      final itemY = item.y;

      // Check if item reaches mouth level
      if (itemY >= mouthY - 20 && itemY <= basketY) {
        final half = _basketWidth / 2;
        if ((itemX >= basketCenterX - half) &&
            (itemX <= basketCenterX + half)) {
          // Remove item immediately - no delay!
          _items.removeAt(i);

          // Eat immediately and add points instantly
          if (item.isFood && item.cake != null) {
            _eatFood(item.cake!);
          } else {
            _eatShoe(item.shoePoints);
          }
          _catchController.forward().then((_) => _catchController.reset());
        }
      }
    }
  }

  void _eatFood(Cake cake) async {
    // Open mouth and add score instantly
    setState(() {
      _mouthOpen = true;
    });
    _incrementScore(); // Instant score increase
    _showEatingEffect();

    // Play eating sound
    try {
      await _sfxPlayer.setVolume(1.0);
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('pou-main/audio/eat.wav'));
    } catch (e) {
      debugPrint('Could not play eating sound: $e');
    }

    // Close mouth quickly
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _mouthOpen = false);
    });
  }

  void _eatShoe(int pointsLoss) {
    setState(() {
      final newScore = _score - pointsLoss;
      _score = newScore < 0 ? 0 : newScore; // don't go below 0
    });
    _showBadEatingEffect();
    // Show negative feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('👟 Yuck! -$pointsLoss points'),
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _showEatingEffect() {
    _eatingController.forward().then((_) {
      _eatingController.reset();
    });
  }

  void _showBadEatingEffect() {
    // Shake animation for eating shoe
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _eatingController.forward().then((_) => _eatingController.reset());
        }
      });
    }
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('catch_highscore') ?? 0;
      _rewardsCount = prefs.getInt('catch_rewards') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('catch_highscore', _highScore);
    await prefs.setInt('catch_rewards', _rewardsCount);
  }

  void _incrementScore() {
    setState(() {
      _score += 1;
      if (_score > _highScore) {
        _highScore = _score;
        _saveHighScore();
      }

      // reward every 10 points
      if (_score % 10 == 0) {
        _grantReward();
      }
    });
    _scoreController.forward().then((_) => _scoreController.reset());
  }

  Future<void> _grantReward() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    Cake? rewardCake;

    // Try to fetch cakes from API and pick a strawberry cake if available
    try {
      final api = ApiService();
      final cakes = await api.fetchCakes();
      rewardCake = cakes.firstWhere(
        (c) => c.title.toLowerCase().contains('strawberry'),
        orElse: () => Cake(
          id: _nextId++,
          title: 'Strawberry Cake (Free)',
          description: 'Free strawberry mini cake dari game!',
          image:
              'https://images.unsplash.com/photo-1551024736-8f23be56a8df?q=80&w=800&auto=format&fit=crop&ixlib=rb-4.0.3&s=1',
          price: 0.0,
          rating: 5.0,
          reviews: 0,
          sweetness: 'Sweet',
          size: 'Mini',
          servings: 1,
        ),
      );
    } catch (e) {
      // fallback to local reward if API fails
      rewardCake = Cake(
        id: _nextId++,
        title: 'Strawberry Cake (Free)',
        description: 'Free strawberry mini cake dari game!',
        image:
            'https://images.unsplash.com/photo-1551024736-8f23be56a8df?q=80&w=800&auto=format&fit=crop&ixlib=rb-4.0.3&s=1',
        price: 0.0,
        rating: 5.0,
        reviews: 0,
        sweetness: 'Sweet',
        size: 'Mini',
        servings: 1,
      );
    }

    // Create a free, unique copy so it doesn't merge with paid items
    final Cake freeCake = Cake(
      id: _nextId++,
      title: '${rewardCake.title} (Free)',
      description: rewardCake.description,
      image: rewardCake.image,
      price: 0.0,
      rating: rewardCake.rating,
      reviews: rewardCake.reviews,
      sweetness: rewardCake.sweetness,
      size: rewardCake.size,
      servings: rewardCake.servings,
    );

    // Add to cart and update rewards
    cart.addItem(freeCake);
    _rewardsCount += 1;
    _saveHighScore();

    // Show reward dialog (uses rewardCake)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient and coin icon
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFF6B35), const Color(0xFFFF8C42)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SUCCESSFULLY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Body content
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Thumbs up icon with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.5 + (value * 0.5),
                          child: Transform.rotate(
                            angle: (1 - value) * 0.5,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFFFB6C1),
                                    const Color(0xFFFF8FA3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF8FA3,
                                    ).withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.thumb_up_rounded,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Stars decoration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.star,
                            color: index == 1
                                ? Colors.amber
                                : Colors.amber.shade300,
                            size: index == 1 ? 24 : 18,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Get coins text
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: 'Get '),
                          TextSpan(
                            text: '10',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF6B35),
                            ),
                          ),
                          const TextSpan(text: ' Points'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Show the rewarded cake (image + title)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: freeCake.image.isNotEmpty
                                ? Image.network(
                                    freeCake.image,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildCakeIcon(),
                                  )
                                : _buildCakeIcon(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  freeCake.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Gratis',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Current coins
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Current Points: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '$_score',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // View Cart button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'View Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final width = MediaQuery.of(context).size.width;
    setState(() {
      _basketX += details.delta.dx / width;
      if (_basketX < 0.05) _basketX = 0.05;
      if (_basketX > 0.95) _basketX = 0.95;
    });
  }

  void _togglePause() {
    setState(() {
      _running = !_running;
      try {
        if (!_running) {
          _bgPlayer.pause();
        } else {
          _bgPlayer.resume();
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFF8F0,
      ), // Warm cream background for cake theme
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B35),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  const BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  AnimatedBuilder(
                    animation: _scoreController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_scoreController.value * 0.3),
                        child: Text(
                          '$_score',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  const BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_highScore',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                const BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _running ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: _running ? Colors.red : Colors.green,
                size: 28,
              ),
              onPressed: _togglePause,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () async {
          if (!_gameStarted) {
            setState(() {
              _gameStarted = true;
            });
            // Start background music when game starts
            try {
              await _bgPlayer.stop();
              await _bgPlayer.play(
                AssetSource('pou-main/audio/food_drop_song.mp3'),
              );
            } catch (e) {
              debugPrint('Could not start background music: $e');
            }
            _startGameLoop();
          }
        },
        onHorizontalDragUpdate: _gameStarted ? _onDragUpdate : null,
        child: Stack(
          children: [
            // Cute cloud decorations
            Positioned(top: 20, left: 20, child: _buildCloud(60)),
            Positioned(top: 50, right: 30, child: _buildCloud(40)),
            Positioned(
              top: 120,
              left: size.width * 0.7,
              child: _buildCloud(50),
            ),

            // falling items (food and shoes) with cute animation
            ..._items.map((item) {
              final left = item.x * size.width - 30;
              return Positioned(
                left: left,
                top: item.y,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 200),
                  tween: Tween(begin: 0.8, end: 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Transform.rotate(
                        angle: sin(item.y * 0.01) * 0.1,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: item.isFood
                                ? Colors.white
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: item.isFood
                                    ? (item.asset != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: Image.asset(
                                                item.asset!,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => _buildCakeIcon(),
                                              ),
                                            )
                                          : _buildCakeIcon())
                                    : (item.asset != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: Image.asset(
                                                item.asset!,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => _buildShoeIcon(),
                                              ),
                                            )
                                          : _buildShoeIcon()),
                              ),
                              // Effect indicator
                              if (item.isFood)
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade400,
                                      borderRadius: BorderRadius.circular(7.5),
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                )
                              else
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade400,
                                      borderRadius: BorderRadius.circular(7.5),
                                    ),
                                    child: const Icon(
                                      Icons.warning,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),

            // Pou character PNG with mouth open/close animation
            Positioned(
              bottom: 80,
              left: _basketX * size.width - _basketWidth / 2,
              child: AnimatedPou(
                mouthOpen: _mouthOpen,
                width: _basketWidth,
                height: 120,
              ),
            ),

            // Tap to Start overlay
            if (!_gameStarted)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 12),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, color: Colors.orange, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Tap to Start',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai permainan dengan tap layar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Instructions card at bottom
            Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    const BoxShadow(color: Colors.black12, blurRadius: 8),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.touch_app,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Drag to Move',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_rewardsCount rewards',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Catch cakes!',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for UI components
  Widget _buildCloud(double size) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.2,
            top: size * 0.1,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(size * 0.15),
              ),
            ),
          ),
          Positioned(
            right: size * 0.15,
            top: size * 0.05,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(size * 0.125),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCakeIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink.shade200, Colors.pink.shade400],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Icon(Icons.cake, color: Colors.white, size: 30),
    );
  }

  Widget _buildShoeIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade600, Colors.grey.shade800],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Icon(
        Icons.sports_baseball, // shoe-like icon
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class AnimatedPou extends StatelessWidget {
  final bool mouthOpen;
  final double width;
  final double height;
  const AnimatedPou({
    super.key,
    required this.mouthOpen,
    this.width = 120,
    this.height = 120,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Body - Classic Pou shape
          Container(
            width: width * 0.88,
            height: height * 0.78,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFFC8A882), const Color(0xFFB8936C)],
              ),
              borderRadius: BorderRadius.circular(width * 0.44),
              border: Border.all(color: const Color(0xFF7A5C3E), width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          // Left Eye - Bigger and more expressive like Pou
          Positioned(
            top: height * 0.25,
            left: width * 0.26,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Pupil
                  Positioned(
                    right: 7,
                    top: 8,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Shine effect
                  Positioned(
                    right: 10,
                    top: 6,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Eye - Bigger and more expressive like Pou
          Positioned(
            top: height * 0.25,
            right: width * 0.26,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Pupil
                  Positioned(
                    left: 7,
                    top: 8,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Shine effect
                  Positioned(
                    left: 10,
                    top: 6,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Left Cheek (Blush)
          Positioned(
            top: height * 0.48,
            left: width * 0.12,
            child: Container(
              width: 18,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB6C1).withOpacity(0.5),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          // Right Cheek (Blush)
          Positioned(
            top: height * 0.48,
            right: width * 0.12,
            child: Container(
              width: 18,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB6C1).withOpacity(0.5),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          // Mouth - Fast and smooth animation like Pou
          Positioned(
            bottom: height * 0.24,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              width: mouthOpen ? 50 : 32,
              height: mouthOpen ? 30 : 14,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: mouthOpen
                      ? [const Color(0xFF6B3410), const Color(0xFF4A2410)]
                      : [const Color(0xFF8B6F47), const Color(0xFF6B4423)],
                ),
                borderRadius: BorderRadius.circular(mouthOpen ? 16 : 10),
                border: Border.all(color: const Color(0xFF3E2723), width: 2.8),
              ),
              child: mouthOpen
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B81),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
