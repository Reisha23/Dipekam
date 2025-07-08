class Rule {
  final List<String> kondisi;
  final String hasil;

  Rule({required this.kondisi, required this.hasil});

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      kondisi: List<String>.from(json['if']),
      hasil: json['then'],
    );
  }
}
