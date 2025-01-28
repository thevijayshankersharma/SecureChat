package com.example.securechat;

import android.telephony.SmsManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.securechat/sms";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("sendSMS")) {
                        String phone = call.argument("phone");
                        String message = call.argument("message");

                        try {
                            SmsManager smsManager = SmsManager.getDefault();
                            smsManager.sendTextMessage(phone, null, message, null, null);
                            result.success(true);
                        } catch (Exception e) {
                            result.error("SEND_SMS_ERROR", "Failed to send SMS", e.getMessage());
                        }
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }
}
