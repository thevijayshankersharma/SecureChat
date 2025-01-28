package com.example.securechat

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.telephony.SmsManager
import io.flutter.plugin.common.MethodChannel

class SmsSender(private val activity: Activity) {
    companion object {
        private const val SMS_SENT = "SMS_SENT"
    }

    fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
        try {
            val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                activity.getSystemService(SmsManager::class.java)
            } else {
                SmsManager.getDefault()
            }
            
            val sentIntent = PendingIntent.getBroadcast(
                activity,
                0,
                Intent(SMS_SENT),
                PendingIntent.FLAG_IMMUTABLE
            )

            // Create a BroadcastReceiver to handle the result of SMS sending
            val sentReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    when (resultCode) {
                        Activity.RESULT_OK -> result.success(true) // SMS sent successfully
                        else -> result.success(false) // SMS failed
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        activity.unregisterReceiver(this)
                    } else {
                        activity.unregisterReceiver(this)
                    }
                }
            }

            // Register the receiver with the appropriate flag for Android 14+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                activity.registerReceiver(sentReceiver, IntentFilter(SMS_SENT), Context.RECEIVER_EXPORTED)
            } else {
                activity.registerReceiver(sentReceiver, IntentFilter(SMS_SENT))
            }

            smsManager.sendTextMessage(phoneNumber, null, message, sentIntent, null)
        } catch (e: Exception) {
            result.error("SEND_SMS_ERROR", e.message, null)
        }
    }
}

