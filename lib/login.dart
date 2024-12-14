import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './models/userModel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailOrUsernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Fungsi untuk login ke API
  Future<void> loginUser(BuildContext context) async {
    final String emailOrUsername = emailOrUsernameController.text;
    final String password = passwordController.text;

    if (emailOrUsername.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    // Memastikan email valid jika yang dimasukkan adalah email
    final bool isEmail = emailOrUsername.contains('@');
    
    // Data yang akan dikirim ke API
    final Map<String, dynamic> loginData = {
      'email': isEmail ? emailOrUsername : null,  // Cek apakah input adalah email
      'username': isEmail ? null : emailOrUsername, // Jika bukan email, anggap itu username
      'password': password,
    };

    try {
      const String apiUrl = 'http://10.0.2.2:3000/auth/login'; 
      
      // Kirim POST request ke server
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Membuat objek User dari respons JSON
        User user = User.fromJson(responseData['user']);
        String token = responseData['token'];

        // Simpan token dan data pengguna ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        prefs.setString('username', user.username);
        prefs.setString('role', user.role);

        // Tampilkan snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        // Navigasi berdasarkan peran pengguna
        if (user.role == 'admin') {
          // Jika admin, arahkan ke halaman admin
          Navigator.pushNamed(context, '/adminHome');
        } else {
          // Jika bukan admin, arahkan ke halaman utama
          Navigator.pushNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome Back 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enter your login information below to access your account',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Email/Username Field
                  TextFormField(
                    controller: emailOrUsernameController,
                    decoration: InputDecoration(
                      labelText: 'Email / Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '********',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                 
                  const SizedBox(height: 40),
                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      loginUser(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Register option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}