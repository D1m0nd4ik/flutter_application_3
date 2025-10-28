class Calculation {
  final int? id;
  final double capital;
  final int term;
  final double rate;
  final double result;
  final DateTime createdAt;

  Calculation({
    this.id,
    required this.capital,
    required this.term,
    required this.rate,
    required this.result,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'capital': capital,
      'term': term,
      'rate': rate,
      'result': result,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Calculation.fromMap(Map<String, dynamic> map) {
    return Calculation(
      id: map['id'] as int?,
      capital: map['capital'] as double,
      term: map['term'] as int,
      rate: map['rate'] as double,
      result: map['result'] as double,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}