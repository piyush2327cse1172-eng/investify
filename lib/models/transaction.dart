class Transaction {
  final int? id;
  final String title;
  final double amount;
  final double roundUpAmount;
  final String category;
  final DateTime date;
  final String type;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.roundUpAmount,
    required this.category,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'roundUpAmount': roundUpAmount,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'type': type,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      roundUpAmount: map['roundUpAmount'],
      category: map['category'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: map['type'],
    );
  }
}