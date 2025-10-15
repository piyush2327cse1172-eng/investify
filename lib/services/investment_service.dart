import '../models/investment_option.dart';

class InvestmentService {
  static List<InvestmentOption> getInvestmentOptions(String riskProfile) {
    final allOptions = [
      InvestmentOption(
        name: 'SIP Mutual Fund',
        description: 'Systematic Investment Plan in diversified equity funds',
        expectedReturn: 12.0,
        riskLevel: 'Moderate',
        timeframe: '3-5 years',
        minAmount: 500,
        category: 'Mutual Fund',
      ),
      InvestmentOption(
        name: 'Gold ETF',
        description: 'Digital gold investment for portfolio diversification',
        expectedReturn: 8.0,
        riskLevel: 'Low',
        timeframe: '1-3 years',
        minAmount: 100,
        category: 'Commodity',
      ),
      InvestmentOption(
        name: 'Index Fund',
        description: 'Low-cost investment tracking market indices',
        expectedReturn: 10.0,
        riskLevel: 'Moderate',
        timeframe: '5+ years',
        minAmount: 1000,
        category: 'Index Fund',
      ),
      InvestmentOption(
        name: 'Liquid Fund',
        description: 'Short-term debt fund for emergency corpus',
        expectedReturn: 4.0,
        riskLevel: 'Very Low',
        timeframe: '3-12 months',
        minAmount: 1000,
        category: 'Debt Fund',
      ),
    ];

    // Filter based on risk profile
    switch (riskProfile.toLowerCase()) {
      case 'beginner':
        return allOptions.where((option) => 
          option.riskLevel == 'Low' || option.riskLevel == 'Very Low').toList();
      case 'intermediate':
        return allOptions.where((option) => 
          option.riskLevel != 'High').toList();
      case 'advanced':
        return allOptions;
      default:
        return allOptions.take(2).toList();
    }
  }

  static double calculatePotentialReturn(double amount, double rate, int months) {
    return amount * (1 + (rate / 100)) * (months / 12);
  }

  static String getInvestmentAdvice(String riskProfile, double monthlyAmount) {
    if (monthlyAmount < 500) {
      return "Start with ₹500/month in Liquid Fund to build emergency corpus first.";
    } else if (monthlyAmount < 2000) {
      return "Diversify: 60% SIP, 30% Gold ETF, 10% Liquid Fund for balanced growth.";
    } else {
      return "Optimal mix: 70% Equity SIP, 20% Index Fund, 10% Gold for long-term wealth.";
    }
  }
}