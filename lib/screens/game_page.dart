import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../models/cake_model.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _rand = Random();
  final AudioPlayer _bgPlayer = AudioPlayer();

  bool _isRunning = false;
  bool _isPaused = false;
  int _score = 0;
  int _timeLeft = 30;
  Offset _targetPos = const Offset(100, 200);
  double _targetSize = 80;
  Timer? _timer;
  Timer? _moveTimer;
  int _moveInterval = 900;

  Color _color1 = const Color(0xFFFF6B35);
  Color _color2 = const Color(0xFFFFF8F0);

  Offset? _explosionPos;
  double _explosionSize = 0;

  void _startGame(BoxConstraints c) {
    if (_isPaused) {
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_timeLeft <= 1) {
          _endGame();
        } else {
          setState(() => _timeLeft--);
        }
      });
      _moveTimer = Timer.periodic(Duration(milliseconds: _moveInterval), (_) {
        _randomizePos(c);
      });
      _bgPlayer.resume();
      return;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _score = 0;
      _timeLeft = 30;
      _targetSize = 80;
      _moveInterval = 900;
      _color1 = const Color(0xFFFF6B35);
      _color2 = const Color(0xFFFFF8F0);
    });

    _bgPlayer.setReleaseMode(ReleaseMode.loop);
    _bgPlayer.play(AssetSource('cute.mp3'));

    _timer?.cancel();
    _moveTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 1) {
        _endGame();
      } else {
        setState(() => _timeLeft--);
      }
    });

    _moveTimer = Timer.periodic(Duration(milliseconds: _moveInterval), (_) {
      _randomizePos(c);
    });
  }

  Widget _smallCakeIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade100, Colors.pink.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.cake, size: 48, color: Colors.white),
      ),
    );
  }

  Future<void> _endGame() async {
    _timer?.cancel();
    _moveTimer?.cancel();
    setState(() => _isRunning = false);

    _bgPlayer.stop();

    if (_score >= 20) {
      // Player earned the reward!
      await _showRewardDialog();
    } else {
      // Show score dialog without reward
      _showScoreDialog();
    }
  }

  Future<void> _showRewardDialog() async {
    Cake rewardCake;
    try {
      final api = ApiService();
      final cakes = await api.fetchCakes();
      rewardCake = cakes.firstWhere(
        (c) => c.title.toLowerCase().contains('strawberry'),
        orElse: () => Cake(
          id: DateTime.now().millisecondsSinceEpoch,
          title: 'Strawberry Cake (Free)',
          description: 'Free strawberry mini dari game',
          image: '',
          price: 0.0,
          rating: 5.0,
          reviews: 0,
          sweetness: 'Sweet',
          size: 'Mini',
          servings: 1,
        ),
      );
    } catch (e) {
      rewardCake = Cake(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Strawberry Cake (Free)',
        description: 'Free strawberry mini dari game',
        image: '',
        price: 0.0,
        rating: 5.0,
        reviews: 0,
        sweetness: 'Sweet',
        size: 'Mini',
        servings: 1,
      );
    }

    // Create free unique copy
    final freeCake = Cake(
      id: DateTime.now().millisecondsSinceEpoch,
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

    // Add to cart via provider
    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      cart.addItem(freeCake);
    } catch (_) {}

    // Show modern reward dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.7 + (value * 0.3),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.chocolateGradient,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.celebration_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'SELAMAT!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Skor: $_score ⭐',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: rewardCake.image.isNotEmpty
                                        ? Image.network(
                                            rewardCake.image,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                _smallCakeIcon(),
                                          )
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.pink.shade200,
                                                  Colors.pink.shade300,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.cake,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          freeCake.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2C2C2C),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade600,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Text(
                                            'GRATIS!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '🎉 Berhasil ditambahkan ke keranjang! 🎉',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryColor,
                                      side: BorderSide(
                                        color: AppTheme.primaryColor,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Main Lagi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (c) => const CartScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Lihat Keranjang',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _randomizePos(BoxConstraints c) {
    final double maxX = c.maxWidth - _targetSize;
    final double maxY = c.maxHeight - _targetSize - 120;
    setState(() {
      _targetPos = Offset(
        _rand.nextDouble() * maxX,
        120 + _rand.nextDouble() * maxY,
      );
    });
  }

  void _randomizeBackground() {
    final List<Color> colors = [
      const Color(0xFFFF6B35),
      const Color(0xFFFF8C42),
      const Color(0xFFFFF8F0),
      const Color(0xFFFFD54F),
      const Color(0xFFF5E6D3),
      const Color(0xFFFFEFE8),
    ];
    setState(() {
      _color1 = colors[_rand.nextInt(colors.length)];
      _color2 = colors[_rand.nextInt(colors.length)];
    });
  }

  void _tapTarget(BoxConstraints c) {
    if (!_isRunning) return;

    SystemSound.play(SystemSoundType.click);
    _randomizeBackground();

    setState(() {
      _score++;
      _explosionPos = _targetPos;
      _explosionSize = _targetSize;

      if (_score % 5 == 0 && _targetSize > 40) {
        _targetSize -= 5;
      }

      if (_score % 4 == 0 && _moveInterval > 400) {
        _moveInterval -= 100;
        _moveTimer?.cancel();
        _moveTimer = Timer.periodic(Duration(milliseconds: _moveInterval), (_) {
          _randomizePos(c);
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _explosionPos = null);
    });

    _randomizePos(c);
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sports_esports_rounded,
                size: 60,
                color: Color(0xFFFF6B35),
              ),
              const SizedBox(height: 16),
              const Text(
                'Game Selesai',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF6B35),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB300),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_score Poin',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Raih 20 poin untuk hadiah!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Main Lagi',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTarget() {
    return Container(
      width: _targetSize,
      height: _targetSize,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/cake.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(_targetSize / 2),
        border: Border.all(color: const Color(0xFFFF6B35), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          "Mini Game",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/backgroundgame.webp',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint(
                      'Failed to load asset: assets/images/backgroundgame.webp -> $error',
                    );
                    return Container(color: const Color(0xFFFFF8F0));
                  },
                ),
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _color1.withOpacity(0.7),
                      _color2.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Chef image in center
              if (!_isRunning)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/chef.webp',
                        width: 400,
                        height: 400,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Failed to load chef.webp: $error');
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 100,
                              color: Color(0xFFFF6B35),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _startGame(constraints),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text(
                          "Tap to Start",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ),

              // Top status bar
              Positioned(
                top: 20,
                left: 16,
                right: 16,
                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Color(0xFFFF6B35)),
                            const SizedBox(width: 6),
                            Text(
                              '$_timeLeft dtk',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFD54F)),
                            const SizedBox(width: 6),
                            Text(
                              '$_score poin',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _isRunning ? _pauseGame : null,
                          icon: const Icon(Icons.pause),
                          label: const Text("Pause"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_explosionPos != null)
                Positioned(
                  left: _explosionPos!.dx + _targetSize / 4,
                  top: _explosionPos!.dy + _targetSize / 4,
                  child: Icon(
                    Icons.star,
                    color: const Color(0xFFFFD54F),
                    size: _explosionSize * 0.6,
                    shadows: const [
                      Shadow(
                        color: Colors.orange,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                left: _targetPos.dx,
                top: _targetPos.dy,
                child: GestureDetector(
                  onTap: () => _tapTarget(constraints),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _isRunning ? 1.0 : 0.0,
                    child: _buildTarget(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _pauseGame() {
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
    _timer?.cancel();
    _moveTimer?.cancel();
    _bgPlayer.pause();
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    _timer?.cancel();
    _moveTimer?.cancel();
    super.dispose();
  }
}
