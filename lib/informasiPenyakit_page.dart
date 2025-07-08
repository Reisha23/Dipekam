import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InformasiPenyakitPage extends StatefulWidget {
  const InformasiPenyakitPage({super.key});

  @override
  State<InformasiPenyakitPage> createState() => _InformasiPenyakitPageState();
}

class _InformasiPenyakitPageState extends State<InformasiPenyakitPage> {
  List<dynamic> _penyakitList = [];

  @override
  void initState() {
    super.initState();
    _loadInformasiPenyakit();
  }

  Future<void> _loadInformasiPenyakit() async {
    final String jsonStr = await rootBundle.loadString('lib/assets/data/informasi_penyakit.json');
    final List<dynamic> data = json.decode(jsonStr);
    setState(() {
      _penyakitList = data;
    });
  }

  void _showDetailPenyakit(Map<String, dynamic> penyakit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  penyakit['nama'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Penjelasan:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List<Widget>.from(
                  (penyakit['penjelasan'] as List<dynamic>).map(
                    (paragraf) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(paragraf, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Gejala:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List<Widget>.from(
                  (penyakit['gejala'] as List<dynamic>).map(
                    (gejala) => Text("• $gejala", style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Penanganan:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  penyakit['penanganan'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Penyakit'),
      ),
      body: _penyakitList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _penyakitList.length,
              itemBuilder: (context, index) {
                final penyakit = _penyakitList[index];
                final penjelasanList = penyakit['penjelasan'] as List<dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      penyakit['nama'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      penjelasanList.isNotEmpty ? penjelasanList.first : '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showDetailPenyakit(penyakit),
                  ),
                );
              },
            ),
    );
  }
}
