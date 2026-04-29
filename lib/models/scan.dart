class Scan {
  final int? id;
  final int userId;
  final double probability;
  final String date;

  Scan({
    this.id,
    required this.userId,
    required this.probability,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'probability': probability,
      'date': date,
    };
  }

  factory Scan.fromMap(Map<String, dynamic> map) {
    return Scan(
      id: map['id'],
      userId: map['user_id'],
      probability: map['probability'],
      date: map['date'],
    );
  }
}
