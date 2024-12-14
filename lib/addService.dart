import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  String price = '';

  Future<void> addService() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');
        if (token == null) {
          throw Exception('Token is missing');
        }

        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/service'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'name': name,
            'description': description,
            'price': price,
          }),
        );

        if (response.statusCode == 201) {
          Navigator.pop(context); // Kembali ke halaman sebelumnya
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service added successfully')),
          );
        } else {
          throw Exception('Failed to add service');
        }
      } catch (error) {
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add service: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Service Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service name';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => name = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => description = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => price = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addService,
                child: const Text('Add Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}