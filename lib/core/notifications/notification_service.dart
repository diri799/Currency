// lib/core/notifications/notification_service.dart
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import '../supabase/supabase_config.dart';

/// Notification service for CurrenSee
/// Handles push notifications via OneSignal and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize notification services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Skip OneSignal initialization in demo mode or on web
      if (kIsWeb) {
        print('Skipping OneSignal initialization on web platform');
        await _initializeLocalNotifications();
        _isInitialized = true;
        return;
      }

      // Initialize OneSignal
      OneSignal.initialize('your-onesignal-app-id'); // Replace with your OneSignal App ID
      
      // Request permission for notifications
      OneSignal.Notifications.requestPermission(true);
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Set up notification handlers
      _setupNotificationHandlers();
      
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize notifications: $e');
      // Still try to initialize local notifications
      try {
        await _initializeLocalNotifications();
        _isInitialized = true;
      } catch (localError) {
        print('Failed to initialize local notifications: $localError');
      }
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Set up notification handlers
  void _setupNotificationHandlers() {
    // Handle OneSignal notification received
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      // You can modify the notification here before it's displayed
      print('Notification received: ${event.notification.title}');
    });

    // Handle OneSignal notification tapped
    OneSignal.Notifications.addClickListener((event) {
      _handleNotificationTap(event.notification);
    });
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    _handleNotificationNavigation(response.payload);
  }

  /// Handle OneSignal notification tap
  void _handleNotificationTap(OSNotification notification) {
    print('OneSignal notification tapped: ${notification.title}');
    _handleNotificationNavigation(notification.additionalData?['route'] as String?);
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(String? route) {
    if (route == null) return;
    
    // Navigate based on route
    switch (route) {
      case 'rate_alert':
        // Navigate to conversion screen
        break;
      case 'news':
        // Navigate to news screen
        break;
      case 'settings':
        // Navigate to settings
        break;
      default:
        // Navigate to home
        break;
    }
  }

  /// Set user ID for OneSignal
  Future<void> setUserId(String userId) async {
    try {
      OneSignal.login(userId);
      
      // Also store in Supabase for server-side notifications
      await SupabaseConfig.database.from('user_notification_tokens').upsert({
        'user_id': userId,
        'onesignal_user_id': userId,
        'platform': 'flutter',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to set user ID: $e');
    }
  }

  /// Remove user ID (on logout)
  Future<void> removeUserId() async {
    try {
      OneSignal.logout();
    } catch (e) {
      print('Failed to remove user ID: $e');
    }
  }

  /// Send local notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channelId = 'currensee_notifications',
    String? channelName = 'CurrenSee Notifications',
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'currensee_notifications',
        'CurrenSee Notifications',
        channelDescription: 'Notifications for CurrenSee app',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      print('Failed to show local notification: $e');
    }
  }

  /// Schedule local notification
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'currensee_scheduled',
        'Scheduled Notifications',
        channelDescription: 'Scheduled notifications for CurrenSee',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.UTC),
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Failed to schedule notification: $e');
    }
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } catch (e) {
      print('Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      print('Failed to cancel all notifications: $e');
    }
  }

  /// Send rate alert notification
  Future<void> sendRateAlertNotification({
    required String fromCurrency,
    required String toCurrency,
    required double currentRate,
    required double targetRate,
    required String alertType,
  }) async {
    final title = 'Rate Alert: $fromCurrency/$toCurrency';
    final body = _buildRateAlertMessage(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      currentRate: currentRate,
      targetRate: targetRate,
      alertType: alertType,
    );

    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: 'rate_alert',
    );
  }

  /// Build rate alert message
  String _buildRateAlertMessage({
    required String fromCurrency,
    required String toCurrency,
    required double currentRate,
    required double targetRate,
    required String alertType,
  }) {
    switch (alertType) {
      case 'above':
        return '$fromCurrency/$toCurrency rate is now $currentRate (above your target of $targetRate)';
      case 'below':
        return '$fromCurrency/$toCurrency rate is now $currentRate (below your target of $targetRate)';
      case 'change':
        return '$fromCurrency/$toCurrency rate changed to $currentRate';
      default:
        return '$fromCurrency/$toCurrency rate is now $currentRate';
    }
  }

  /// Send market news notification
  Future<void> sendMarketNewsNotification({
    required String title,
    required String body,
  }) async {
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: 'news',
    );
  }

  /// Check notification permissions
  Future<bool> areNotificationsEnabled() async {
    try {
      final result = await _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled();
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final result = await _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
