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
    _bgPlayer.play(AssetSource('assets/cute.mp3'));

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
          title: 'Strawberry Cake',
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
        title: 'Strawberry Cake',
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
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with gradient and trophy icon
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Trophy icon with glow effect
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'CONGRATS!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.yellow[300],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Skor: $_score',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content area
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            // Success message with icon
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.green[700],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'The gift has been successfully added to the shopping cart!',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Cake reward card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange[50]!,
                                    Colors.pink[50]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(0xFFFF6B35).withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Cake image
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: rewardCake.image.isNotEmpty
                                          ? Image.network(
                                              rewardCake.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.pink[300]!,
                                                          Colors.pink[400]!,
                                                        ],
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.cake_rounded,
                                                      color: Colors.white,
                                                      size: 45,
                                                    ),
                                                  ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.pink[300]!,
                                                    Colors.pink[400]!,
                                                  ],
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.cake_rounded,
                                                color: Colors.white,
                                                size: 45,
                                              ),
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
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[800],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.green[600]!,
                                                Colors.green[500]!,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.card_giftcard_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              const Text(
                                                'FREE',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Color(0xFFFF6B35),
                                      side: BorderSide(
                                        color: Color(0xFFFF6B35),
                                        width: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.replay_rounded, size: 20),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Play Again',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
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
                                      backgroundColor: Color(0xFFFF6B35),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_rounded,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Cart',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
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
                    'Play Again',
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
