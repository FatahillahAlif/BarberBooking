import 'dart:convert';
import 'package:barberbooking/addBarber.dart';
import 'package:barberbooking/editBarber.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ManageBarbersPage extends StatefulWidget {
  const ManageBarbersPage({super.key});

  @override
  _ManageBarberPageState createState() => _ManageBarberPageState();
}

class _ManageBarberPageState extends State<ManageBarbersPage> {
  List<dynamic> barbers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBarbers();
  }

  // Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi untuk mengambil data barber dari backend
  Future<void> fetchBarbers() async {
    const url = 'http://10.0.2.2:3000/barber';
    final token = await getToken();

    if (token == null) {
      showError('Token tidak ditemukan. Silakan login kembali.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          barbers = data['barbers']; 

          // Mengurutkan barber berdasarkan nama (ascending)
          barbers.sort((a, b) => a['name'].compareTo(b['name']));

          isLoading = false;
        });
      } else {
        showError('Gagal memuat data barber: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      showError('Terjadi kesalahan saat memuat data barber: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk menampilkan pesan error
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Fungsi untuk menambahkan barber
  void addBarber() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBarberPage()),
    );
    if (result == true) {
      fetchBarbers();
    }
  }

  // Fungsi untuk mengedit barber
  void editBarber(int index) async {
    final barber = barbers[index];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBarberPage(
          barberId: barber['id'],
          barberData: barber,
        ),
      ),
    );
    if (result == true) {
      fetchBarbers();
    }
  }

  // Fungsi untuk menghapus barber
  Future<void> deleteBarber(int barberId) async {
    final urlBase = 'http://10.0.2.2:3000/barber/$barberId';
    final token = await getToken();

    if (token == null) {
      showError('Token tidak ditemukan. Silakan login kembali.');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(urlBase),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        showError('Barber berhasil dihapus!');
        fetchBarbers();
      } else {
        showError('Gagal menghapus barber: ${response.statusCode}');
      }
    } catch (error) {
      showError('Terjadi kesalahan saat menghapus barber: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Barber'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addBarber,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: barbers.length,
              itemBuilder: (context, index) {
                final barber = barbers[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    title: Text(barber['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(barber['position']),
                        const SizedBox(height: 4),
                        if (barber['schedules'] != null && barber['schedules'].isNotEmpty)
                          ...barber['schedules'].map<Widget>((schedule) {
                            return Text(
                              'Hari: ${schedule['day_of_week']}, Jam: ${schedule['start_time']} - ${schedule['end_time']}',
                              style: const TextStyle(fontSize: 12),
                            );
                          }).toList(),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => editBarber(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteBarber(barber['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}