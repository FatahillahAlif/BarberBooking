import 'dart:convert';
import 'package:barberbooking/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingController untuk setiap field
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }
  
  @override
  void dispose() {
    // Membersihkan controller untuk menghindari kebocoran memori
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi untuk mengambil data profil user dari backend
  Future<void> fetchProfile() async {
    final token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Token tidak ditemukan, silakan login kembali')),
      );
      return;
    }

    final url =
        'http://10.0.2.2:3000/auth/profile'; // URL untuk mengambil data profil
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _fullNameController.text = data['user']['full_name'] ?? '';
          _usernameController.text = data['user']['username'] ?? '';
          _emailController.text = data['user']['email'] ?? '';
          _phoneNumberController.text = data['user']['phone_number'] ?? '';
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Gagal memuat data profil: ${response.statusCode}')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk mengirim data yang diedit ke backend
  Future<void> updateProfile() async {
    final token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Token tidak ditemukan, silakan login kembali')),
      );
      return;
    }

    final url = 'http://10.0.2.2:3000/auth/profile';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'full_name': _fullNameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
          'phone_number': _phoneNumberController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        setState(() {
          _fullNameController.text = data['user']['full_name'];
          _usernameController.text = data['user']['username'];
          _emailController.text = data['user']['email'];
          _phoneNumberController.text = data['user']['phone_number'];
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', data['user']['username']);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal mengupdate profil: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
            style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const Text('Nama Lengkap:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama lengkap tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Username:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_circle),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Email:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Phone Number:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor telepon tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 50),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              updateProfile();
                            }
                          },
                          child: const Text('Simpan Perubahan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
