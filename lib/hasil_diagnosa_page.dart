import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import '../utils/forward_chaining.dart';

class HasilDiagnosaPage extends StatefulWidget {
  final String hasilDiagnosa;

  const HasilDiagnosaPage({super.key, required this.hasilDiagnosa});

  @override
  _HasilDiagnosaPageState createState() => _HasilDiagnosaPageState();
}

class _HasilDiagnosaPageState extends State<HasilDiagnosaPage> {
  final TextEditingController _nomorKambingController = TextEditingController();
  late String _tanggalDiagnosa;

  @override
  void initState() {
    super.initState();
    _tanggalDiagnosa = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _simpanRiwayat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic> hasilBaru = {
      'nomor': _nomorKambingController.text,
      'tanggal': _tanggalDiagnosa,
      'penyakit': widget.hasilDiagnosa.split('\n').first,
      'penanganan': widget.hasilDiagnosa.split('\n').length > 1
          ? widget.hasilDiagnosa.split('\n').sublist(1).join('\n')
          : '',
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('riwayat_diagnosa')
        .add(hasilBaru);
  }

  void _handleSimpan() async {
    if (_nomorKambingController.text.isNotEmpty) {
      await _simpanRiwayat();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Hasil diagnosa berhasil disimpan!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text('Harap isi nomor kambing terlebih dahulu.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Diagnosa'),
        backgroundColor: const Color.fromARGB(255, 125, 194, 250),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hasil Diagnosa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.hasilDiagnosa,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nomorKambingController,
              decoration: InputDecoration(
                labelText: 'Nomor Kambing',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.date_range, size: 24, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  'Tanggal Diagnosa: $_tanggalDiagnosa',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _handleSimpan,
                icon: const Icon(Icons.save_alt),
                label: const Text(
                  'Simpan Hasil',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}