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
import android.util.Log

class SmsSender(private val activity: Activity) {
    companion object {
        private const val SMS_SENT = "com.example.securechat.SMS_SENT"
        private const val TAG = "SmsSender"
    }

    fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
        val sentIntent = PendingIntent.getBroadcast(
            activity,
            0,
            Intent(SMS_SENT),
            PendingIntent.FLAG_IMMUTABLE
        )

        val sentReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (resultCode) {
                    Activity.RESULT_OK -> {
                        Log.d(TAG, "SMS sent successfully")
                        result.success(true)
                    }
                    else -> {
                        Log.e(TAG, "Failed to send SMS: $resultCode")
                        result.success(false)
                    }
                }
            }
        }

        activity.registerReceiver(
            sentReceiver,
            IntentFilter(SMS_SENT),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) Context.RECEIVER_EXPORTED else 0
        )

        try {
            val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                activity.getSystemService(SmsManager::class.java)
            } else {
                SmsManager.getDefault()
            }
            smsManager.sendTextMessage(phoneNumber, null, message, sentIntent, null)
        } catch (e: Exception) {
            Log.e(TAG, "Error sending SMS: ${e.message}")
            result.error("SEND_SMS_ERROR", e.message, null)
            activity.unregisterReceiver(sentReceiver)
        }
    }
}

