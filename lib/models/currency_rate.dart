class CurrencyRate {
  final double amount;
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime date;

  const CurrencyRate({
    required this.amount,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.date,
  });

  factory CurrencyRate.fromJson(
    Map<String, dynamic> json,
    String targetCurrency,
  ) {
    return CurrencyRate(
      amount: json['amount'].toDouble(),
      baseCurrency: json['base'],
      targetCurrency: targetCurrency,
      rate: json['rates'][targetCurrency].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  double get convertedAmount => amount * rate;

  @override
  String toString() {
    return '$amount $baseCurrency = ${convertedAmount.toStringAsFixed(2)} $targetCurrency';
  }
}
