class TransactionModel {
  final String transactionId;
  final String userId;
  final String type; // 'pemasukan' atau 'pengeluaran'
  final String source;
  final double amount;
  final String description;
  final String transactionDate; // Format 'YYYY-MM-DD'
  final String? createdAt;
  final String? updatedAt;

  TransactionModel({
    required this.transactionId,
    required this.userId,
    required this.type,
    required this.source,
    required this.amount,
    required this.description,
    required this.transactionDate,
    this.createdAt,
    this.updatedAt,
  });

  bool get isIncome => type.toLowerCase() == 'pemasukan';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'pengeluaran',
      source: json['source']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString() ?? '',
      transactionDate: json['transaction_date']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'user_id': userId,
      'type': type,
      'source': source,
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  TransactionModel copyWith({
    String? transactionId,
    String? userId,
    String? type,
    String? source,
    double? amount,
    String? description,
    String? transactionDate,
    String? createdAt,
    String? updatedAt,
  }) {
    return TransactionModel(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
