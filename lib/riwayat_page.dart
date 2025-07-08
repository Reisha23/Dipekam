import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiwayatPage extends StatefulWidget {
  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final user = FirebaseAuth.instance.currentUser;
  late CollectionReference _riwayatRef;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _riwayatRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('riwayat_diagnosa');
    }
  }

  Future<void> _hapusRiwayat(String docId) async {
    await _riwayatRef.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Diagnosa'),
        backgroundColor: const Color(0xFF0D8EEB),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Silakan login terlebih dahulu.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _riwayatRef.orderBy('tanggal', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada riwayat.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final data = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final riwayat = item.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          'Kambing No: ${riwayat['nomor']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tanggal   : ${riwayat['tanggal']}'),
                              Text('Penyakit  : ${riwayat['penyakit']}'),
                              Text('Penanganan: ${riwayat['penanganan']}'),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Riwayat?'),
                                content: const Text('Yakin ingin menghapus data ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _hapusRiwayat(item.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
