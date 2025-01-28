package com.example.securechat

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.securechat/sms"
    private lateinit var smsSender: SmsSender

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        smsSender = SmsSender(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val phone = call.argument<String>("phone")
                    val message = call.argument<String>("message")

                    if (phone == null || message == null) {
                        result.error("INVALID_ARGUMENTS", "Phone number or message is null", null)
                        return@setMethodCallHandler
                    }

                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            smsSender.sendSMS(phone, message, result)
                        } catch (e: Exception) {
                            Log.e("MainActivity", "Error in sendSMS: ${e.message}")
                            result.error("UNEXPECTED_ERROR", e.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}

