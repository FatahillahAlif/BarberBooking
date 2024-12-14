import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBarberPage extends StatefulWidget {
  const AddBarberPage({super.key});

  @override
  _AddBarberPageState createState() => _AddBarberPageState();
}

class _AddBarberPageState extends State<AddBarberPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Controllers untuk input jadwal kerja per hari
  final List<TextEditingController> scheduleControllers = List.generate(7, (_) => TextEditingController());

  // Fungsi untuk memilih gambar dari galeri atau kamera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileExtension = file.path.split('.').last.toLowerCase();
      
      // Memastikan hanya gambar dengan ekstensi yang valid yang dipilih
      if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
        setState(() {
          _image = file;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only image files are allowed!')),
        );
      }
    }
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi untuk menambah barber baru dengan gambar dan jadwal
  Future<void> addBarber() async {
    final name = nameController.text;
    final description = descriptionController.text;
    final position = positionController.text;

    if (name.isEmpty || description.isEmpty || position.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and select an image!')),
      );
      return;
    }

    // Mengambil jadwal kerja dari input
    List<Map<String, String>> schedules = [];
    for (int i = 0; i < 7; i++) {
      final scheduleText = scheduleControllers[i].text;
      if (scheduleText.isNotEmpty) {
        final times = scheduleText.split(' - ');
        if (times.length == 2) {
          schedules.add({
            'day_of_week': _getDayOfWeek(i),
            'start_time': times[0],
            'end_time': times[1],
          });
        }
      }
    }

    if (schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide at least one valid schedule.')),
      );
      return;
    }

    const url = 'http://10.0.2.2:3000/barber';

    final String? token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token not found! Please log in again.')),
      );
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('image', _image!.path,))
        ..fields['name'] = name
        ..fields['description'] = description
        ..fields['position'] = position
        ..fields['schedules'] = json.encode(schedules);

      var response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barber Added Successfully')),
        );
        Navigator.pop(context, true);
      } else {
        String responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add barber. Error: $responseBody')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  // Fungsi untuk mendapatkan nama hari berdasarkan index
  String _getDayOfWeek(int index) {
    switch (index) {
      case 0:
        return 'Senin';
      case 1:
        return 'Selasa';
      case 2:
        return 'Rabu';
      case 3:
        return 'Kamis';
      case 4:
        return 'Jumat';
      case 5:
        return 'Sabtu';
      case 6:
        return 'Minggu';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Barber'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 10),
              _image == null
                  ? const Text('No image selected')
                  : Image.file(_image!),
              const SizedBox(height: 20),
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
              const SizedBox(height: 10),
              for (int i = 0; i < 7; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: scheduleControllers[i],
                    decoration: InputDecoration(
                      labelText: 'Jadwal ${_getDayOfWeek(i)}',
                      hintText: 'Contoh: 09:00 - 17:00',
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addBarber,
                child: const Text('Add Barber'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}