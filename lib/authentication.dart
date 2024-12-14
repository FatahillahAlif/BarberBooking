import 'package:flutter/material.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final List<TextEditingController> _codeControllers = List.generate(4, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Authentication',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter the authentication code that we have sent to your email',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Code Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _codeControllers[index],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 3) {
                            FocusScope.of(context).nextFocus(); // Pindah ke input berikutnya
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Send Button
                ElevatedButton(
                  onPressed: () {
                    // Logika setelah memasukkan kode
                    String code = _codeControllers.map((controller) => controller.text).join();
                    // Lakukan sesuatu dengan code
                    print("Kode dimasukkan: $code");
                    Navigator.pushNamed(context, '/home'); // Navigasi ke Home setelah kode dimasukkan
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000000), // Tombol dengan warna hitam
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                // Resend Code
                TextButton(
                  onPressed: () {
                    // Logika untuk mengirim ulang kode
                  },
                  child: const Text(
                    'Have not received the code?',
                    style: TextStyle(color: Colors.black),
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