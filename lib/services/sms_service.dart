import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../models/transaction.dart';
import 'database_service.dart';

class SmsService {
  static final SmsQuery _query = SmsQuery();
  static StreamSubscription? _smsSubscription;
  static DateTime? _lastProcessedTime;

  static Future<bool> requestPermissions() async {
    final permissions = [
      Permission.sms,
      Permission.phone,
    ];
    
    final statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  static Future<void> startListening() async {
    if (!await requestPermissions()) return;
    
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
    if (!await requestPermissions()) return;
    await _processRecentMessages();
  }

  static Future<void> _processExistingMessages() async {
    final messages = await _query.querySms(
      kinds: [SmsQueryKind.Inbox],
      count: 50,
    );
    
    _lastProcessedTime = DateTime.now();
    
    for (final message in messages) {
      await _processMessage(message);
    }
  }

  static Future<void> _processRecentMessages() async {
    final messages = await _query.querySms(
      kinds: [SmsQueryKind.Inbox],
      count: 20,
    );
    
    final cutoffTime = _lastProcessedTime ?? DateTime.now().subtract(const Duration(hours: 1));
    
    for (final message in messages) {
      if (message.date != null && message.date!.isAfter(cutoffTime)) {
        await _processMessage(message);
      }
    }
    
    _lastProcessedTime = DateTime.now();
  }

  static Future<void> _processMessage(SmsMessage message) async {
    final transaction = _parseTransactionFromSms(message);
    if (transaction != null) {
      await DatabaseService.insertTransaction(transaction);
    }
  }

  static Transaction? _parseTransactionFromSms(SmsMessage message) {
    final body = message.body?.toLowerCase() ?? '';
    final sender = message.address ?? '';
    
    // Skip if not from bank/payment service
    if (!_isTransactionSms(sender, body)) return null;
    
    // Extract amount
    final amount = _extractAmount(body);
    if (amount == null || amount <= 0) return null;
    
    // Skip if credit/refund
    if (_isCredit(body)) return null;
    
    // Extract merchant/description
    final title = _extractMerchant(body) ?? 'Transaction';
    
    // Categorize transaction
    final category = _categorizeTransaction(title, body);
    
    // Calculate round-up
    final roundUpAmount = _calculateRoundUp(amount);
    
    return Transaction(
      title: title,
      amount: amount,
      roundUpAmount: roundUpAmount,
      category: category,
      date: message.date ?? DateTime.now(),
      type: 'expense',
    );
  }

  static bool _isTransactionSms(String sender, String body) {
    final bankKeywords = ['bank', 'upi', 'paytm', 'gpay', 'phonepe', 'bhim', 'axis', 'hdfc', 'sbi', 'icici'];
    final transactionKeywords = ['debited', 'paid', 'spent', 'transaction', 'purchase'];
    
    return bankKeywords.any((keyword) => sender.toLowerCase().contains(keyword)) &&
           transactionKeywords.any((keyword) => body.contains(keyword));
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

  static bool _isCredit(String body) {
    return body.contains('credited') || body.contains('received') || body.contains('refund');
  }

  static String? _extractMerchant(String body) {
    // Try to extract merchant name from common patterns
    final patterns = [
      RegExp(r'at\s+([A-Z][A-Z\s]+)', caseSensitive: false),
      RegExp(r'to\s+([A-Z][A-Z\s]+)', caseSensitive: false),
      RegExp(r'merchant\s+([A-Z][A-Z\s]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    
    return null;
  }

  static String _categorizeTransaction(String title, String body) {
    final foodKeywords = ['restaurant', 'cafe', 'food', 'zomato', 'swiggy', 'dominos', 'mcd'];
    final transportKeywords = ['uber', 'ola', 'metro', 'bus', 'taxi', 'fuel', 'petrol'];
    final shoppingKeywords = ['amazon', 'flipkart', 'mall', 'store', 'shop'];
    final entertainmentKeywords = ['movie', 'cinema', 'netflix', 'spotify', 'game'];
    final billsKeywords = ['electricity', 'gas', 'water', 'mobile', 'internet', 'recharge'];
    
    final text = '$title $body'.toLowerCase();
    
    if (foodKeywords.any((k) => text.contains(k))) return 'Food';
    if (transportKeywords.any((k) => text.contains(k))) return 'Transport';
    if (shoppingKeywords.any((k) => text.contains(k))) return 'Shopping';
    if (entertainmentKeywords.any((k) => text.contains(k))) return 'Entertainment';
    if (billsKeywords.any((k) => text.contains(k))) return 'Bills';
    
    return 'Shopping';
  }

  static double _calculateRoundUp(double amount) {
    final roundedUp = ((amount / 5).ceil() * 5).toDouble();
    return roundedUp - amount;
  }
}