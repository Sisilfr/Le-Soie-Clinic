import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _amReminderOn = false;
  bool _pmReminderOn = false;

  int _amHour = 7;
  int _amMinute = 0;
  int _pmHour = 21;
  int _pmMinute = 0;

  bool get amReminderOn => _amReminderOn;
  bool get pmReminderOn => _pmReminderOn;
  int get amHour => _amHour;
  int get amMinute => _amMinute;
  int get pmHour => _pmHour;
  int get pmMinute => _pmMinute;

  NotificationProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _amReminderOn = prefs.getBool('amReminderOn') ?? false;
    _pmReminderOn = prefs.getBool('pmReminderOn') ?? false;
    _amHour = prefs.getInt('amHour') ?? 7;
    _amMinute = prefs.getInt('amMinute') ?? 0;
    _pmHour = prefs.getInt('pmHour') ?? 21;
    _pmMinute = prefs.getInt('pmMinute') ?? 0;
    notifyListeners();
  }

  Future<void> toggleAmReminder(bool value) async {
    print('NotificationProvider: toggleAmReminder() value=$value');
    if (value) {
      await _notificationService.requestPermissions();
    }
    _amReminderOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('amReminderOn', value);
    notifyListeners();

    if (value) {
      await _notificationService.scheduleDailyReminder(
        id: 1,
        title: 'Rutinitas Skincare AM',
        body: 'Jangan lupa untuk membersihkan wajah dan memakai sunscreen!',
        hour: _amHour,
        minute: _amMinute,
      );
    } else {
      await _notificationService.cancelReminder(1);
    }
  }

  Future<void> toggleForPmReminder(bool value) async {
    print('NotificationProvider: toggleForPmReminder() value=$value');
    if (value) {
      await _notificationService.requestPermissions();
    }
    _pmReminderOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pmReminderOn', value);
    notifyListeners();

    if (value) {
      await _notificationService.scheduleDailyReminder(
        id: 2,
        title: 'Rutinitas Skincare PM',
        body: 'Saatnya membersihkan wajah dan merawat kulit sebelum tidur!',
        hour: _pmHour,
        minute: _pmMinute,
      );
    } else {
      await _notificationService.cancelReminder(2);
    }
  }

  Future<void> updateAmTime(int hour, int minute) async {
    print('NotificationProvider: updateAmTime() to $hour:$minute');
    _amHour = hour;
    _amMinute = minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('amHour', hour);
    await prefs.setInt('amMinute', minute);
    notifyListeners();

    if (_amReminderOn) {
      await _notificationService.scheduleDailyReminder(
        id: 1,
        title: 'Rutinitas Skincare AM',
        body: 'Jangan lupa untuk membersihkan wajah dan memakai sunscreen!',
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> updatePmTime(int hour, int minute) async {
    print('NotificationProvider: updatePmTime() to $hour:$minute');
    _pmHour = hour;
    _pmMinute = minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pmHour', hour);
    await prefs.setInt('pmMinute', minute);
    notifyListeners();

    if (_pmReminderOn) {
      await _notificationService.scheduleDailyReminder(
        id: 2,
        title: 'Rutinitas Skincare PM',
        body: 'Saatnya membersihkan wajah dan merawat kulit sebelum tidur!',
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> testInstantNotification() async {
    print('NotificationProvider: testInstantNotification() triggered');
    await _notificationService.showInstantNotification(
      id: 99,
      title: 'Tes Notifikasi Instan Le Soie',
      body: 'Jika Anda melihat ini, konfigurasi dasar notifikasi lokal telah berjalan dengan baik!',
    );
  }
}
