import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'addService.dart';  // Import AddServicePage
import 'editService.dart'; // Import EditServicePage

class ManageServicesPage extends StatefulWidget {
  const ManageServicesPage({super.key});

  @override
  _ManageServicesPageState createState() => _ManageServicesPageState();
}

class _ManageServicesPageState extends State<ManageServicesPage> {
  List<Map<String, dynamic>> services = [];

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  // Fungsi untuk mengambil services
  Future<void> fetchServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token is missing');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/service/services'),
        headers: {
          'Authorization': 'Bearer $token', // Menambahkan token untuk otentikasi
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          services = List<Map<String, dynamic>>.from(data['services']);
        });
      } else {
        throw Exception('Failed to load services');
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load services: $error')),
      );
    }
  }

  // Fungsi untuk menghapus service
  Future<void> deleteService(int serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token is missing');
      }

      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/service/$serviceId'), // Perbaiki URL
        headers: {
          'Authorization': 'Bearer $token', // Menambahkan token untuk otentikasi
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          services.removeWhere((service) => service['id'] == serviceId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete service');
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete service: $error')),
      );
    }
  }

  // Fungsi untuk menambah service
  void addService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddServicePage()),
    ).then((_) => fetchServices());
  }

  // Fungsi untuk mengedit service
  void editService(Map<String, dynamic> service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServicePage(service: service),
      ),
    ).then((_) => fetchServices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addService,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Agar teks rata kiri
                children: [
                  Text(
                    service['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['description'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp. ${service['price']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => editService(service),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteService(service['id']),
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