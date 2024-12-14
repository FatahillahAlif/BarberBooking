import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditServicePage extends StatefulWidget {
  final Map<String, dynamic> service;

  const EditServicePage({super.key, required this.service});

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  late String price;

  @override
  void initState() {
    super.initState();
    name = widget.service['name'];
    description = widget.service['description'];
    price = widget.service['price'].toString();
  }

  Future<void> updateService() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');
        if (token == null) {
          throw Exception('Token is missing');
        }

        final response = await http.put(
          Uri.parse('http://10.0.2.2:3000/service/${widget.service['id']}'),
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

        if (response.statusCode == 200) {
          Navigator.pop(context); // Kembali ke halaman sebelumnya
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service updated successfully')),
          );
        } else {
          throw Exception('Failed to update service');
        }
      } catch (error) {
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update service: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
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
                initialValue: description,
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
                initialValue: price,
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
                onPressed: updateService,
                child: const Text('Update Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}