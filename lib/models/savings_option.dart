class SavingsOption {
  final String name;
  final String description;
  final double expectedReturn;
  final String riskLevel;
  final String timeframe;
  final double minAmount;
  final String category;

  SavingsOption({
    required this.name,
    required this.description,
    required this.expectedReturn,
    required this.riskLevel,
    required this.timeframe,
    required this.minAmount,
    required this.category,
  });
}