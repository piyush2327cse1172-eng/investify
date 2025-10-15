package com.example.inverstify

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_reader"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSmsMessages" -> {
                    try {
                        val smsReader = SmsReader(this)
                        val messages = smsReader.getSmsMessages()
                        result.success(messages)
                    } catch (e: Exception) {
                        result.error("SMS_ERROR", "Failed to read SMS: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
