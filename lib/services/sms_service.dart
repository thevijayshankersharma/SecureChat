import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  static const platform = MethodChannel('com.example.securechat/sms');

  Future<Map<String, dynamic>> sendSMS(String phoneNumber, String message) async {
    if (await Permission.sms.request().isGranted) {
      try {
        final Map<String, dynamic> result = await platform.invokeMethod('sendSMS', {
          'phone': phoneNumber,
          'message': message,
        });
        return result;
      } on PlatformException catch (e) {
        print("Failed to send SMS: '${e.message}'.");
        return {'success': false, 'error': e.message};
      }
    }
    return {'success': false, 'error': 'SMS permission not granted'};
  }
}