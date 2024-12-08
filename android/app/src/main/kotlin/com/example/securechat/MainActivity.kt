package com.example.securechat

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.telephony.SmsManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.securechat/sms"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSMS") {
                val phone = call.argument<String>("phone")
                val message = call.argument<String>("message")
                if (phone == null || message == null) {
                    result.error("INVALID_ARGUMENTS", "Phone number or message is null", null)
                    return@setMethodCallHandler
                }
                sendSMS(phone, message, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
        try {
            val smsManager = SmsManager.getDefault()
            val sentIntent = PendingIntent.getBroadcast(this, 0, Intent("SMS_SENT"), PendingIntent.FLAG_IMMUTABLE)
            
            val sentReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    when (resultCode) {
                        Activity.RESULT_OK -> result.success(true)
                        else -> result.success(false)
                    }
                    context?.unregisterReceiver(this)
                }
            }
            
            registerReceiver(sentReceiver, IntentFilter("SMS_SENT"))
            smsManager.sendTextMessage(phoneNumber, null, message, sentIntent, null)
        } catch (e: Exception) {
            result.error("SEND_SMS_ERROR", e.message, null)
        }
    }
}

