import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final LocationService _locationService = LocationService();
  String _deliveryAddress = 'Pilih lokasi pengiriman';
  String _selectedPaymentMethod = 'BCA';
  bool _isLoadingLocation = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'BCA',
      'name': 'Bank BCA',
      'subtitle': 'Transfer ke rekening BCA',
      'icon': Icons.account_balance,
    },
    {
      'id': 'BNI',
      'name': 'Bank BNI',
      'subtitle': 'Transfer ke rekening BNI',
      'icon': Icons.account_balance,
    },
    {
      'id': 'BRI',
      'name': 'Bank BRI',
      'subtitle': 'Transfer ke rekening BRI',
      'icon': Icons.account_balance,
    },
    {
      'id': 'QRIS',
      'name': 'QRIS',
      'subtitle': 'Scan QR Code untuk bayar',
      'icon': Icons.qr_code,
    },
    {
      'id': 'COD',
      'name': 'Cash on Delivery',
      'subtitle': 'Bayar saat barang diterima',
      'icon': Icons.money,
    },
  ];

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final hasPermission = await _locationService.checkPermission();
      if (hasPermission) {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          final locationName = await _locationService.getLocationName(position);
          setState(() {
            _deliveryAddress = locationName;
          });
        }
      }
    } catch (e) {
      debugPrint('Error detecting location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _processCheckout() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
      ),
    );

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Checkout dan ambil order yang baru dibuat
    final userId = auth.currentUser?.id;
    final createdOrder = await cart.checkout(
      userId,
      settings.timezone,
      _selectedPaymentMethod,
      _deliveryAddress,
    );

    // Close loading
    if (mounted) Navigator.pop(context);

    // Navigate to success screen dengan order yang baru dibuat
    if (mounted && createdOrder != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(order: createdOrder),
        ),
      );
    } else {
      // Jika gagal membuat order, tampilkan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memproses pesanan. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final subtotal = cart.totalPrice;
    final shippingFee = 5.0;
    final total = subtotal + shippingFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Location Section
                  _buildSectionTitle('Delivery Location'),
                  const SizedBox(height: 12),
                  _buildDeliveryLocationCard(),
                  const SizedBox(height: 24),

                  // Payment Method Section
                  _buildSectionTitle('Payment Method'),
                  const SizedBox(height: 12),
                  _buildPaymentMethodList(),
                  const SizedBox(height: 24),

                  // Order Info Section
                  _buildSectionTitle('Order Info'),
                  const SizedBox(height: 12),
                  _buildOrderInfoCard(
                    subtotal: subtotal,
                    shippingFee: shippingFee,
                    total: total,
                    settings: settings,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Checkout Button
          _buildBottomBar(total, settings),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D2D2D),
      ),
    );
  }

  Widget _buildDeliveryLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFFFF6B35),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '2 Pesos, Mahalaxmi St.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoadingLocation
                      ? 'Mendeteksi lokasi...'
                      : _deliveryAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            color: const Color(0xFF999999),
            onPressed: () {
              _showAddressDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodList() {
    return Column(
      children: _paymentMethods.map((method) {
        final isSelected = _selectedPaymentMethod == method['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method['id'];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF6B35)
                    : const Color(0xFFEEEEEE),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    method['icon'],
                    color: const Color(0xFF2D2D2D),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method['subtitle'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderInfoCard({
    required double subtotal,
    required double shippingFee,
    required double total,
    required SettingsProvider settings,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow('Subtotal', settings.formatPrice(subtotal)),
          const SizedBox(height: 12),
          _buildInfoRow('Shipping Fee', settings.formatPrice(shippingFee)),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _buildInfoRow('Total', settings.formatPrice(total), isTotal: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF2D2D2D) : const Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFFFF6B35) : const Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(double total, SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _processCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'PROCEED (${settings.formatPrice(total)})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Pilih Alamat',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location, color: Color(0xFFFF6B35)),
              title: const Text('Deteksi Lokasi Saya'),
              onTap: () {
                Navigator.pop(context);
                _detectLocation();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_location,
                color: Color(0xFFFF6B35),
              ),
              title: const Text('Input Manual'),
              onTap: () {
                Navigator.pop(context);
                _showManualAddressInput();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showManualAddressInput() {
    final controller = TextEditingController(text: _deliveryAddress);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Alamat Pengiriman',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Masukkan alamat lengkap',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _deliveryAddress = controller.text;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
