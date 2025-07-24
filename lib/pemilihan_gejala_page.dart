import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/forward_chaining.dart';
import 'hasil_diagnosa_page.dart';

class Gejala {
  final String id;
  final String nama;

  Gejala({required this.id, required this.nama});

  factory Gejala.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Gejala(
      id: data['id'],
      nama: data['nama'],
    );
  }
}

class PemilihanGejalaPage extends StatefulWidget {
  @override
  _PemilihanGejalaPageState createState() => _PemilihanGejalaPageState();
}

class _PemilihanGejalaPageState extends State<PemilihanGejalaPage> {
  List<Gejala> _gejalaList = [];
  List<Gejala> _filteredGejalaList = [];
  Set<String> _selectedGejala = {};
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGejala();
    _searchController.addListener(_filterGejala);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGejala() async {
    final snapshot = await FirebaseFirestore.instance.collection('gejala').get();
    final gejalaList = snapshot.docs.map((doc) => Gejala.fromFirestore(doc)).toList();
    setState(() {
      _gejalaList = gejalaList;
      _filteredGejalaList = gejalaList;
    });
  }

  void _filterGejala() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredGejalaList = _gejalaList.where((gejala) {
        return gejala.nama.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _diagnosa() async {
    if (_selectedGejala.length < 2) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Gejala tidak valid!"),
          content: Text("Tidak dapat menemukan penyakit. Silahkan pilih minimal dua gejala."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final hasil = await forwardChaining(_selectedGejala.toList());

    if (hasil != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasilDiagnosaPage(
            hasilDiagnosa: "${hasil.penyakit.nama}\n\nPenanganan: ${hasil.penyakit.penanganan}",
            jumlahCocok: hasil.jumlahCocok,
            totalGejala: hasil.totalGejala,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Tidak ditemukan"),
          content: Text("Gejala tidak cocok dengan aturan manapun."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
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
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Cari gejala...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ),
        backgroundColor: const Color(0xFF0D8EEB),
      ),
      body: _filteredGejalaList.isEmpty
          ? Center(child: Text('harap login terlebih dahulu agar bisa menggunakan fitur diagnosa!'))
          : ListView(
              children: _filteredGejalaList.map((gejala) {
                return CheckboxListTile(
                  title: Text(gejala.nama),
                  value: _selectedGejala.contains(gejala.id),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedGejala.add(gejala.id);
                      } else {
                        _selectedGejala.remove(gejala.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: _diagnosa,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF0D8EEB),
          ),
          child: Text(
            "Diagnosa",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}