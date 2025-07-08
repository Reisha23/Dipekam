import 'package:cloud_firestore/cloud_firestore.dart';

class Penyakit {
  final String id;
  final String nama;
  final String penanganan;

  Penyakit({required this.id, required this.nama, required this.penanganan});

  factory Penyakit.fromFirestore(Map<String, dynamic> json) {
    return Penyakit(
      id: json['id'],
      nama: json['nama'],
      penanganan: json['penanganan'],
    );
  }
}

class Rule {
  final List<String> kondisi;
  final String hasil;

  Rule({required this.kondisi, required this.hasil});

  factory Rule.fromFirestore(Map<String, dynamic> json) {
    return Rule(
      kondisi: List<String>.from(json['if']),
      hasil: json['then'],
    );
  }
}

Future<Penyakit?> forwardChaining(List<String> selectedGejala) async {
  final firestore = FirebaseFirestore.instance;

  // Ambil data rules
  final rulesSnapshot = await firestore.collection('rules').get();
  final List<Rule> rules = rulesSnapshot.docs
      .map((doc) => Rule.fromFirestore(doc.data()))
      .toList();

  // Ambil data penyakit
  final penyakitSnapshot = await firestore.collection('penyakit').get();
  final List<Penyakit> penyakitList = penyakitSnapshot.docs
      .map((doc) => Penyakit.fromFirestore(doc.data()))
      .toList();

  Map<String, double> hasilPersentase = {};

  for (var rule in rules) {
    final jumlahCocok = rule.kondisi
        .where((gejala) => selectedGejala.contains(gejala))
        .length;
    final totalKondisi = rule.kondisi.length;

    if (jumlahCocok > 0) {
      double persen = jumlahCocok / totalKondisi;
      hasilPersentase[rule.hasil] = persen;
    }
  }

  if (hasilPersentase.isEmpty) return null;

  String penyakitTerbaikId = hasilPersentase.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key;

  return penyakitList.firstWhere((p) => p.id == penyakitTerbaikId, orElse: () => Penyakit(id: '-', nama: 'Tidak Diketahui', penanganan: '-'));
}
