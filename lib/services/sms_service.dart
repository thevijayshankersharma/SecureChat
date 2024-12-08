import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  static const platform = MethodChannel('com.example.securechat/sms');

  Future<bool> sendSMS(String phoneNumber, String message) async {
    if (await Permission.sms.request().isGranted) {
      try {
        final bool result = await platform.invokeMethod('sendSMS', {
          'phone': phoneNumber,
          'message': message,
        });
        return result;
      } on PlatformException catch (e) {
        print("Failed to send SMS: '${e.message}'.");
        return false;
      }
    }
    return false;
  }
}

