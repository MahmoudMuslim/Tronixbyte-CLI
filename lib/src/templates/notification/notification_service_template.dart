String getNotificationServiceTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true);
    const linuxInit = LinuxInitializationSettings(defaultActionName: 'Open notification');
    
    await _notifications.initialize(
      const InitializationSettings(
        android: androidInit, 
        iOS: darwinInit, 
        macOS: darwinInit,
        linux: linuxInit,
      ),
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click if needed
      });

    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificAction<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            description: 'This channel is used for important notifications.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ));
    }
  }

  static Future<void> showLocalNotification(RemoteNotification notification) async {
    await _notifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ));
  }
}
""";
