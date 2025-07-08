import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InformasiKambingPage extends StatefulWidget {
  InformasiKambingPage({super.key});

  @override
  _InformasiKambingPageState createState() => _InformasiKambingPageState();
}

class _InformasiKambingPageState extends State<InformasiKambingPage> {
  List<dynamic> informasiKambing = [];

  @override
  void initState() {
    super.initState();
    loadInformasiKambing();
  }

  Future<void> loadInformasiKambing() async {
    final String response =
        await rootBundle.loadString('lib/assets/data/informasi_kambing.json');
    final data = await json.decode(response);
    setState(() {
      informasiKambing = data;
    });
  }

  String getImageAsset(String jenis) {
    // Nama file disesuaikan dengan format lowercase dan underscore
    String fileName = jenis.toLowerCase().replaceAll(" ", "_") + ".jpg";
    return 'lib/assets/images/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informasi Kambing"),
      ),
      body: ListView.builder(
        itemCount: informasiKambing.length,
        itemBuilder: (context, index) {
          final kambing = informasiKambing[index];
          final jenis = kambing['jenis'];
          final penjelasan = kambing['penjelasan'];
          final imagePath = getImageAsset(jenis);

          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: Center(child: Text('Gambar tidak ditemukan')),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    jenis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(penjelasan),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
