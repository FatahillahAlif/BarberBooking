import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

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
                  'Forget Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter your email address to receive a password reset link',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Email Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),
                // Send Reset Link Button
                ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman Authentication setelah mengirim link reset
                    Navigator.pushNamed(context, '/authentication'); // Navigasi ke Authentication
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000000), // Warna hitam
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Send Reset Link',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                // Remembered your password? Login
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Remembered your password? "),
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize:const Size(2, 0),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/');
                        },
                        child: const Text(
                          'Login',
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
    );
  }
}
