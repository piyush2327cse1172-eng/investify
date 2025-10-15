package com.example.inverstify

import android.content.Context
import android.database.Cursor
import android.net.Uri
import io.flutter.plugin.common.MethodChannel

class SmsReader(private val context: Context) {
    
    fun getSmsMessages(): List<Map<String, String>> {
        val messages = mutableListOf<Map<String, String>>()
        
        try {
            val uri = Uri.parse("content://sms/inbox")
            val cursor: Cursor? = context.contentResolver.query(
                uri,
                arrayOf("address", "body", "date"),
                null,
                null,
                "date DESC LIMIT 20"
            )
            
            cursor?.use {
                while (it.moveToNext()) {
                    val sender = it.getString(it.getColumnIndexOrThrow("address")) ?: ""
                    val body = it.getString(it.getColumnIndexOrThrow("body")) ?: ""
                    val date = it.getLong(it.getColumnIndexOrThrow("date"))
                    
                    messages.add(mapOf(
                        "sender" to sender,
                        "body" to body,
                        "date" to date.toString()
                    ))
                }
            }
        } catch (e: Exception) {
            println("Error reading SMS: ${e.message}")
        }
        
        return messages
    }
}