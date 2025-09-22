class CreditCard {
  final String id;
  final String cardNumber;
  final String cardType;
  final String cvv;
  final String issuingCountry;
  final DateTime createdAt;
  final String? frontImagePath;
  final String? backImagePath;

  CreditCard({
    required this.id, 
    required this.cardNumber, 
    required this.cardType, 
    required this.cvv, 
    required this.issuingCountry, 
    required this.createdAt,
    this.frontImagePath,
    this.backImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardType': cardType,
      'cvv': cvv,
      'issuingCountry': issuingCountry,
      'createdAt': createdAt.toIso8601String(),
      'frontImagePath': frontImagePath,
      'backImagePath': backImagePath,
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'], 
      cardNumber: map['cardNumber'], 
      cardType: map['cardType'], 
      cvv: map['cvv'], 
      issuingCountry: map['issuingCountry'], 
      createdAt: DateTime.parse(map['createdAt']),
      frontImagePath: map['frontImagePath'],
      backImagePath: map['backImagePath'],
    );
  }

  CreditCard copyWith({
    String? id,
    String? cardNumber,
    String? cardType,
    String? cvv,
    String? issuingCountry,
    DateTime? createdAt,
    String? frontImagePath,
    String? backImagePath,
  }) {
    return CreditCard(
      id: id ?? this.id, 
      cardNumber: cardNumber ?? this.cardNumber, 
      cardType: cardType ?? this.cardType, 
      cvv: cvv ?? this.cvv, 
      issuingCountry: issuingCountry ?? this.issuingCountry, 
      createdAt: createdAt ?? this.createdAt,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
    );
  }
}