package com.example.securechat

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.telephony.SmsManager
import io.flutter.plugin.common.MethodChannel

class SmsSender(private val activity: Activity) {
    companion object {
        private const val SMS_SENT = "SMS_SENT"
    }

    fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
        try {
            val smsManager = SmsManager.getDefault()
            val sentIntent = PendingIntent.getBroadcast(
                activity,
                0,
                Intent(SMS_SENT),
                PendingIntent.FLAG_IMMUTABLE
            )

            val sentReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    when (resultCode) {
                        Activity.RESULT_OK -> result.success(true)
                        else -> result.success(false)
                    }
                    activity.unregisterReceiver(this)
                }
            }

            activity.registerReceiver(sentReceiver, IntentFilter(SMS_SENT))
            smsManager.sendTextMessage(phoneNumber, null, message, sentIntent, null)
        } catch (e: Exception) {
            result.error("SEND_SMS_ERROR", e.message, null)
        }
    }
}

