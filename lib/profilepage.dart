import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';
  String full_name = '';
  String phoneNumber = '';
  String role = '';

  

  // Fungsi untuk mengambil data profil pengguna
  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      // Jika token tidak ada, redirect ke halaman login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      const String apiUrl = 'http://10.0.2.2:3000/auth/profile'; // URL ke endpoint profil
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Kirim token dalam header
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          username = responseData['user']['username'] ?? 'Unknown Username';
          email = responseData['user']['email'] ?? 'Unknown Email';
          full_name = responseData['user']['full_name'] ?? 'Unknown Full Name';
          phoneNumber = responseData['user']['phone_number'] ?? 'Unknown Phone';
          role = responseData['user']['role'] ?? 'Unknown Role';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data profil: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile(); // Ambil data profil saat halaman dimuat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username.isNotEmpty ? username : full_name, // Ganti full_name dengan username
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        email.isNotEmpty ? email : 'Email not found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: () {
                      // Clear token and navigate to login page
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.remove('token');
                        Navigator.pushNamed(context, '/');
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
            ListTile(
              title: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                Navigator.pushNamed(context, '/editprofile');
              },
            ),
            ListTile(
              title: const Text(
                'Security',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                Navigator.pushNamed(context, '/security');
              },
            ),
          ],
        ),
      ),
    );
  }
}