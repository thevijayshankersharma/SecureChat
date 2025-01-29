package com.example.securechat

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SmsReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            for (message in messages) {
                val sender = message.originatingAddress
                val messageBody = message.messageBody
                Log.d(TAG, "SMS received from: $sender, message: $messageBody")
                
                // Send the received SMS to MainActivity
                if (context is MainActivity) {
                    context.onSmsReceived(sender ?: "", messageBody)
                }
            }
        }
    }
}

