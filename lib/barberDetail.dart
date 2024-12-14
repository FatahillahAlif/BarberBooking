import 'package:flutter/material.dart';

class BarberDetailPage extends StatelessWidget {
  final String name;
  final String position;
  final String image;
  final String description; // Deskripsi kelebihan dan pengalaman
  final String schedule; // Jadwal kerja

  const BarberDetailPage({
    super.key,
    required this.name,
    required this.position,
    required this.image,
    required this.description,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barber'),
        centerTitle: true, // Memastikan teks judul berada di tengah
      ),
      body: SingleChildScrollView( // Agar konten bisa di-scroll jika panjang
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Menyelaraskan teks ke kiri
            children: [
              // Foto Barber di tengah
              Center(
                child: CircleAvatar(
                  radius: 100, // Ukuran lingkaran
                  backgroundImage: NetworkImage(image),
                ),
              ),
              const SizedBox(height: 16),
              
              // Nama dan posisi Barber di tengah
              Center(
                child: Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      position,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Deskripsi
              Text(
                'Deskripsi :',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Container dengan ukuran yang konsisten
              Container(
                width: double.infinity, // Menyesuaikan dengan lebar layar
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.transparent, 
                  border: Border.all(color: Colors.grey[300]!), 
                  borderRadius: BorderRadius.circular(12.0), 
                ),
                child: Align(  // Menggunakan Align untuk memusatkan teks
                  alignment: Alignment.centerLeft,  // Menyelaraskan teks ke kiri
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.left, // Ganti ke left align
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Jadwal Kerja
              Text(
                'Jadwal Kerja :',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Container dengan ukuran yang konsisten
              Container(
                width: double.infinity, // Menyesuaikan dengan lebar layar
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Align(  // Menggunakan Align untuk memusatkan teks
                  alignment: Alignment.centerLeft,  // Menyelaraskan teks ke kiri
                  child: Text(
                    schedule,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.left, // Ganti ke left align
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}