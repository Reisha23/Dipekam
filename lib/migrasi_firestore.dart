import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateGejalaData() async {
  final firestore = FirebaseFirestore.instance;
  final String jsonStr = await rootBundle.loadString('lib/assets/gejala.json');
  final List<dynamic> data = json.decode(jsonStr);

  for (var item in data) {
    await firestore.collection('gejala').doc(item['id']).set({
      'id': item['id'],
      'nama': item['nama'],
    });
  }

  print("✅ Migrasi data gejala selesai.");
}

Future<void> migratePenyakitData() async {
  final firestore = FirebaseFirestore.instance;
  final String jsonStr = await rootBundle.loadString('lib/assets/penyakit.json');
  final List<dynamic> data = json.decode(jsonStr);

  for (var item in data) {
    await firestore.collection('penyakit').doc(item['id']).set({
      'id': item['id'],
      'nama': item['nama'],
      'penanganan': item['penanganan'],
    });
  }

  print('✅ Migrasi data penyakit selesai.');
}

Future<void> migrateRulesData() async {
  final firestore = FirebaseFirestore.instance;
  final String jsonStr = await rootBundle.loadString('lib/assets/rules.json');
  final List<dynamic> data = json.decode(jsonStr);

  for (var item in data) {
    await firestore.collection('rules').add({
      'if': List<String>.from(item['if']),
      'then': item['then'],
    });
  }

  print('✅ Migrasi data rules selesai.');
}