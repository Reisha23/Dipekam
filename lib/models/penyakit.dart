class Penyakit {
  final String id;
  final String nama;
  final String penanganan;

  Penyakit({required this.id, required this.nama, required this.penanganan});

  factory Penyakit.fromJson(Map<String, dynamic> json) {
    return Penyakit(
      id: json['id'],
      nama: json['nama'],
      penanganan: json['penanganan'],
    );
  }
}
