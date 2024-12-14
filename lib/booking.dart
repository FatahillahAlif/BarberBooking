import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingBarberPage extends StatefulWidget {
  const BookingBarberPage({super.key});

  @override
  State<BookingBarberPage> createState() => _BookingBarberPageState();
}

class _BookingBarberPageState extends State<BookingBarberPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedBarber;
  String? selectedService;
  List<dynamic> barbers = [];
  List<Map<String, dynamic>> services = [];

  @override
  void initState() {
    super.initState();
    _fetchBarbers();
    _fetchServices();
  }

  // Mengambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Mengambil data barber dari backend
  Future<void> _fetchBarbers() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/barber'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['barbers'] != null) {
          setState(() {
            barbers = data['barbers'];
            barbers.sort((a, b) => a['name'].compareTo(b['name']));
          });
        } else {
          throw Exception("Data barber tidak ditemukan.");
        }
      } else {
        throw Exception("Failed to load barbers");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Mengambil data services dari backend
  Future<void> _fetchServices() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/service/services'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Periksa apakah field 'services' ada dalam data
        if (data['services'] != null) {
          setState(() {
            // Pastikan data['services'] adalah list dan bukan objek
            services = List<Map<String, dynamic>>.from(data['services']);
          });
        } else {
          throw Exception("Data services tidak ditemukan.");
        }
      } else {
        throw Exception("Failed to load services");
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Mengirim data booking ke backend
  Future<void> _submitBooking() async {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedBarber == null ||
        selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field harus diisi!"),
        ),
      );
      return;
    }

    // Format tanggal dan waktu
    String formattedDate =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
    String formattedTime =
        "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    // Data booking
    final bookingData = {
      "barberId": selectedBarber,
      "serviceId": selectedService,
      "bookingDate": formattedDate,
      "bookingTime": formattedTime,
    };

    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/booking'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(bookingData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking berhasil dibuat!")),
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${errorResponse['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Pilih tanggal
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Pilih waktu
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Barber',
            style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Barber:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                items: barbers.map<DropdownMenuItem<String>>((barber) {
                  return DropdownMenuItem<String>(
                    value: barber['id'].toString(),
                    child: Text(barber['name']),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBarber = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                hint: const Text('Pilih Barber'),
              ),
              const SizedBox(height: 20),
              const Text('Layanan:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                items: services.map<DropdownMenuItem<String>>((service) {
                  return DropdownMenuItem<String>(
                    value: service['id'].toString(),
                    child: Text(service['name']),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedService = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                hint: const Text('Pilih layanan'),
              ),
              const SizedBox(height: 20),
              const Text('Tanggal:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(selectedDate == null
                      ? 'Pilih tanggal'
                      : '${selectedDate!.toLocal()}'.split(' ')[0]),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Waktu:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(selectedTime == null
                      ? 'Pilih waktu'
                      : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'),
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: _submitBooking,
                child: const Text(
                  'Booking Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
