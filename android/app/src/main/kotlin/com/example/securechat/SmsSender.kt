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
        private const val SMS_SENT = "SMS_SENT"
        private const val TAG = "SmsSender"
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
                    try {
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
                    } catch (e: Exception) {
                        Log.e(TAG, "Error in onReceive: ${e.message}")
                        result.error("RECEIVE_ERROR", e.message, null)
                    } finally {
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                context?.unregisterReceiver(this)
                            } else {
                                activity.unregisterReceiver(this)
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "Error unregistering receiver: ${e.message}")
                        }
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
            Log.e(TAG, "Error sending SMS: ${e.message}")
            result.error("SEND_SMS_ERROR", e.message, null)
        }
    }
}

