import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/transaction.dart';
import 'database_service.dart';

class SmsService {
  static DateTime? _lastProcessedTime;

  static Future<bool> requestPermissions() async {
    try {
      // Check current status
      final smsStatus = await Permission.sms.status;
      print('Current SMS permission: $smsStatus');
      
      if (smsStatus.isGranted) {
        return true;
      }
      
      // Request SMS permission
      final result = await Permission.sms.request();
      print('SMS permission result: $result');
      
      return result.isGranted;
    } catch (e) {
      print('Permission request error: $e');
      return false;
    }
  }

  static Future<void> startListening() async {
    // Start background SMS listener
    _startBackgroundListener();
    
    // Process existing messages
    await _processExistingMessages();
  }

  static void _startBackgroundListener() {
    // Use a timer to periodically check for new messages
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      await refreshSmsData();
    });
  }

  static Future<void> refreshSmsData() async {
    try {
      await _processRecentMessages();
    } catch (e) {
      print('SMS refresh error: $e');
    }
  }

  static Future<void> _processExistingMessages() async {
    try {
      final hasPermission = await requestPermissions();
      if (hasPermission) {
        print('SMS permission granted - fetching real messages');
        await _fetchSmsMessages();
        print('SMS service initialized successfully');
      } else {
        print('No SMS permission granted');
      }
      _lastProcessedTime = DateTime.now();
    } catch (e) {
      print('Error processing existing messages: $e');
    }
  }

  static Future<void> _processRecentMessages() async {
    try {
      final hasPermission = await requestPermissions();
      if (hasPermission) {
        print('SMS refresh: Fetching recent messages');
        await _fetchSmsMessages();
        print('SMS refresh completed successfully');
      } else {
        print('SMS refresh: No permission available');
      }
      _lastProcessedTime = DateTime.now();
    } catch (e) {
      print('Error processing recent messages: $e');
    }
  }

  static Future<void> _fetchSmsMessages() async {
    try {
      const platform = MethodChannel('sms_reader');
      final List<dynamic> messages = await platform.invokeMethod('getSmsMessages');
      
      print('Found ${messages.length} SMS messages');
      
      for (var message in messages.take(10)) {
        final sender = message['sender'] ?? 'Unknown';
        final body = message['body'] ?? '';
        final date = message['date'] ?? '';
        
        print('SMS from $sender: ${body.length > 50 ? body.substring(0, 50) + '...' : body}');
        
        if (_isTransactionSms(sender, body)) {
          final amount = _extractAmount(body);
          if (amount != null) {
            print('Found transaction: ₹$amount from $sender');
          }
        }
      }
    } catch (e) {
      print('Error fetching SMS messages: $e');
      print('SMS reading not implemented yet - using debug mode');
    }
  }

  static bool _isTransactionSms(String sender, String body) {
    final bankKeywords = ['bank', 'upi', 'paytm', 'gpay', 'phonepe', 'bhim', 'axis', 'hdfc', 'sbi', 'icici'];
    final transactionKeywords = ['debited', 'paid', 'spent', 'transaction', 'purchase'];
    
    return bankKeywords.any((keyword) => sender.toLowerCase().contains(keyword)) &&
           transactionKeywords.any((keyword) => body.toLowerCase().contains(keyword));
  }

  static double? _extractAmount(String body) {
    final regex = RegExp(r'(?:rs\.?|₹)\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null) {
      final amountStr = match.group(1)?.replaceAll(',', '');
      return double.tryParse(amountStr ?? '');
    }
    return null;
  }



  static double _calculateRoundUp(double amount) {
    final roundedUp = ((amount / 5).ceil() * 5).toDouble();
    return roundedUp - amount;
  }



  // Debug method to show mock SMS data
  static Future<List<Map<String, String>>> debugFetchAllSms() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return [{'error': 'SMS permissions not granted', 'sender': '', 'body': '', 'date': '', 'isTransaction': '', 'amount': ''}];
    }
    
    return [
      {
        'sender': 'HDFC Bank',
        'body': 'Rs.247 debited from account for UPI transaction at STARBUCKS',
        'date': DateTime.now().toString(),
        'isTransaction': 'true',
        'amount': '247.0',
      },
      {
        'sender': 'AXIS Bank', 
        'body': 'Rs.156 debited for Uber ride payment via UPI',
        'date': DateTime.now().subtract(const Duration(hours: 2)).toString(),
        'isTransaction': 'true',
        'amount': '156.0',
      },
    ];
  }

  // Simple test method
  static Future<String> testSmsAccess() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return 'No SMS permission';
    return 'Success: SMS permission granted (ready for real SMS processing)';
  }
}