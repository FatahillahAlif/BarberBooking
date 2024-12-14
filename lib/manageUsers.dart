import 'package:flutter/material.dart';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Users',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Daftar pengguna (dummy data)
          ListView.builder(
            shrinkWrap: true,
            itemCount: 5, // Ganti dengan jumlah pengguna
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text('User $index'),
                  subtitle: const Text('Email: user@example.com'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Aksi untuk mengedit pengguna
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}