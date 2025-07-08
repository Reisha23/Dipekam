import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
//import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import 'dart:io';

class NotificationScheduler extends StatefulWidget {
  @override
  _NotificationSchedulerState createState() => _NotificationSchedulerState();
}

class _NotificationSchedulerState extends State<NotificationScheduler> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _scheduledList = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotification();
    _loadSavedSchedules();
  }

  Future<void> _initializeNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.request().isGranted) {
      debugPrint("Izin notifikasi diberikan");
    }

    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.request().isGranted) {
        debugPrint("Izin exact alarm diberikan");
      } else {
        debugPrint("Izin exact alarm tidak diberikan, gunakan alternatif!");
      }
    }
  }

  Future<void> _saveSchedules() async {
    if (_scheduledList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Belum ada jadwal untuk disimpan!"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final encodedList = jsonEncode(_scheduledList.map((e) => {'date': e['date'].toIso8601String(), 'desc': e['desc']}).toList());
    await prefs.setString('saved_schedules', encodedList);
    debugPrint("Jadwal berhasil disimpan!");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Jadwal berhasil disimpan!"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _loadSavedSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSchedules = prefs.getString('saved_schedules');
    if (savedSchedules != null) {
      final decodedList = jsonDecode(savedSchedules) as List<dynamic>;
      setState(() {
        _scheduledList.clear();
        _scheduledList.addAll(decodedList.map((e) => {'date': DateTime.parse(e['date']), 'desc': e['desc']}).toList());
      });
    }
  }

  void _pickMultipleDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        for (final date in _getDateRange(picked.start, picked.end)) {
          _scheduledList.add({"date": date, "desc": _descriptionController.text});
        }
      });
    }
  }

  List<DateTime> _getDateRange(DateTime start, DateTime end) {
    return List.generate(
      end.difference(start).inDays + 1,
      (index) => start.add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Penjadwalan Rencana', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D8EEB),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
              ),
              child: Column(
                children: [
                  const Text("Atur Jadwal Pengingat", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Rencana',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.note_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _pickMultipleDates,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Pilih Rentang Tanggal"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D8EEB)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _scheduledList.length,
                itemBuilder: (context, index) {
                  final item = _scheduledList[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: const Icon(Icons.date_range, color: Color(0xFF0D8EEB)),
                      title: Text(DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(item['date'])),
                      subtitle: Text(item['desc'], style: const TextStyle(color: Colors.black54)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _scheduledList.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSchedules,
                icon: const Icon(Icons.save_alt),
                label: const Text("Simpan Jadwal"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}