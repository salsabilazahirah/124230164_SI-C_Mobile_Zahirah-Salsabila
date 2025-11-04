import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'toko_kue_channel',
          'Toko Kue Notifications',
          channelDescription: 'Notifications for Toko Kue app',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> showCartNotification(String cakeName, int quantity) async {
    await showNotification(
      title: 'Ditambahkan ke Keranjang! 🛒',
      body: '$cakeName (x$quantity) berhasil ditambahkan',
    );
  }

  Future<void> showCartUpdateNotification(
    String cakeName,
    int quantity,
    String action,
  ) async {
    String message = '';
    if (action == 'increase') {
      message = '$cakeName ditambah menjadi x$quantity';
    } else if (action == 'decrease') {
      message = '$cakeName dikurangi menjadi x$quantity';
    }

    await showNotification(title: 'Keranjang Diperbarui 📝', body: message);
  }

  Future<void> showItemRemovedNotification(String cakeName) async {
    await showNotification(
      title: 'Item Dihapus 🗑️',
      body: '$cakeName telah dihapus dari keranjang',
    );
  }

  Future<void> showOrderNotification(
    double total,
    int items, [
    String? timezone,
  ]) async {
    final timeStr = timezone != null ? ' at ${_getCurrentTime(timezone)}' : '';
    await showNotification(
      title: 'Order Placed Successfully! 🎉',
      body: '$items items ordered for \$${total.toStringAsFixed(2)}$timeStr',
    );
  }

  String _getCurrentTime(String timezone) {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $timezone';
  }
}
