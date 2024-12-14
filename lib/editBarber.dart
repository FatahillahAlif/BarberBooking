import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker

class EditBarberPage extends StatefulWidget {
  final int barberId;
  final Map<String, dynamic> barberData;

  const EditBarberPage({super.key, required this.barberId, required this.barberData});

  @override
  _EditBarberPageState createState() => _EditBarberPageState();
}

class _EditBarberPageState extends State<EditBarberPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController positionController;

  late List<TextEditingController> scheduleControllers;

  File? _imageFile; // Variable untuk menyimpan file gambar

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.barberData['name']);
    descriptionController = TextEditingController(text: widget.barberData['description']);
    positionController = TextEditingController(text: widget.barberData['position']);

    scheduleControllers = List.generate(7, (index) {
      String scheduleText = '';
      if (widget.barberData['schedules'] != null) {
        var schedule = widget.barberData['schedules'].firstWhere(
          (s) => s['day_of_week'] == _getDayOfWeek(index),
          orElse: () => null,
        );
        if (schedule != null) {
          String startTime = schedule['start_time'] ?? '';
          String endTime = schedule['end_time'] ?? '';
          if (startTime.isNotEmpty && endTime.isNotEmpty) {
            scheduleText = '$startTime - $endTime';
          }
        }
      }
      return TextEditingController(text: scheduleText);
    });
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi untuk memilih gambar menggunakan ImagePicker
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Pilih dari galeri
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> updateBarber() async {
    final name = nameController.text;
    final description = descriptionController.text;
    final position = positionController.text;

    if (name.isEmpty || description.isEmpty || position.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    final schedules = List.generate(7, (index) {
      final schedule = scheduleControllers[index].text;
      if (schedule.isNotEmpty) {
        final times = schedule.split(' - ');
        if (times.length == 2) {
          if (_isValidTimeFormat(times[0]) && _isValidTimeFormat(times[1])) {
            return {
              'day_of_week': _getDayOfWeek(index),
              'start_time': times[0],
              'end_time': times[1],
            };
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid time format! Use HH:MM - HH:MM')),
            );
            return null;
          }
        }
      }
      return null;
    }).where((schedule) => schedule != null).toList();

    if (schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide at least one valid schedule.')),
      );
      return;
    }

    final url = 'http://10.0.2.2:3000/barber/${widget.barberId}';

    final String? token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token not found! Please log in again.')),
      );
      return;
    }

    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url))
        ..headers.addAll({
          'Authorization': 'Bearer $token',
        })
        ..fields['name'] = name
        ..fields['description'] = description
        ..fields['position'] = position
        ..fields['schedules'] = jsonEncode(schedules);

      // Jika gambar ada, tambahkan gambar ke request
      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barber Updated Successfully')),
        );
        Navigator.pop(context, true);
      } else {
        final responseBody = await response.stream.bytesToString();
        final message = jsonDecode(responseBody)['message'] ?? 'Failed to update barber';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  String _getDayOfWeek(int index) {
    switch (index) {
      case 0: return 'Senin';
      case 1: return 'Selasa';
      case 2: return 'Rabu';
      case 3: return 'Kamis';
      case 4: return 'Jumat';
      case 5: return 'Sabtu';
      case 6: return 'Minggu';
      default: return '';
    }
  }

  bool _isValidTimeFormat(String time) {
    final timeRegex = RegExp(r'^[0-2]?[0-9]:[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Barber'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Input gambar berada di atas
              _imageFile == null
                  ? const Text('No image selected')
                  : Image.file(_imageFile!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage, // Fungsi untuk memilih gambar
                child: const Text('Choose Image'),
              ),
              const SizedBox(height: 20),
              // Input field untuk nama, deskripsi, dan posisi
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Barber Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
              const SizedBox(height: 20),
              // Input jadwal per hari
              for (int i = 0; i < 7; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: scheduleControllers[i],
                    decoration: InputDecoration(
                      labelText: 'Jadwal ${_getDayOfWeek(i)}',
                      hintText: 'Contoh: 9:00 - 12:00',
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateBarber,
                child: const Text('Update Barber'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}