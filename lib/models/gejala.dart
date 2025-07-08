class Gejala {
  final String id;
  final String nama;

  Gejala({required this.id, required this.nama});

  factory Gejala.fromJson(Map<String, dynamic> json) {
    return Gejala(id: json['id'], nama: json['nama']);
  }
}
