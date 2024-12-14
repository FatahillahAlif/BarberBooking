import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoryBookingPage extends StatefulWidget {
  const HistoryBookingPage({super.key});

  @override
  State<HistoryBookingPage> createState() => _HistoryBookingPageState();
}

class _HistoryBookingPageState extends State<HistoryBookingPage> {
  String selectedCategory = 'Pending';
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookingHistory();
  }

  Future<void> fetchBookingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is missing');
      }

      final url = Uri.parse('http://10.0.2.2:3000/booking/history');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bookings = data['bookings'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Booking', style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ToggleButtons untuk switch kategori
            ToggleButtons(
              isSelected: [
                selectedCategory == 'Pending',
                selectedCategory == 'Confirm',
                selectedCategory == 'Complete',
                selectedCategory == 'Canceled',
              ],
              onPressed: (int index) {
                setState(() {
                  selectedCategory = ['Pending', 'Confirm', 'Complete', 'Canceled'][index];
                });
              },
              // Properti untuk kustomisasi gaya
              color: Colors.grey, 
              selectedColor: Colors.white, 
              fillColor: Colors.black, 
              borderColor: Colors.grey, 
              selectedBorderColor: Colors.black, 
              borderWidth: 2.0, 
              borderRadius: BorderRadius.circular(10.0), 
              constraints: const BoxConstraints(
                minWidth: 80, 
                minHeight: 40, 
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Pending', textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Confirm', textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Complete', textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Canceled', textAlign: TextAlign.center),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: getBookingList(selectedCategory),
                  ),
          ],
        ),
      ),
    );
  }

  Widget getBookingList(String category) {
    final filteredBookings = bookings.where((booking) {
      if (category == 'Pending') {
        return booking['status'] == 'pending';
      } else if (category == 'Confirm') {
        return booking['status'] == 'confirmed';
      } else if (category == 'Complete') {
        return booking['status'] == 'completed';
      } else {
        return booking['status'] == 'cancelled';
      }
    }).toList();

    return ListView.builder(
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        return bookingCard(
          booking['service']['name'],
          booking['barber']['name'],
          formatDate(booking['booking_date']),
          booking['booking_time'],
          booking['status'],
        );
      },
    );
  }

  Widget bookingCard(String service, String barber, String date, String time, String status) {
    Color statusColor;

    // Set warna berdasarkan status
    if (status == 'pending') {
      statusColor = Colors.orangeAccent;
    } else if (status == 'confirmed') {
      statusColor = Colors.blueAccent;
    } else if (status == 'completed') {
      statusColor = Colors.greenAccent;
    } else {
      statusColor = Colors.redAccent;
    }

    return Card(
      elevation: 5, // Tinggi bayangan
      shadowColor: statusColor.withOpacity(0.5), // Warna bayangan sesuai status
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Membulatkan sudut kartu
      ),
      color: Colors.white, // Warna latar belakang kartu
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Warna putih untuk latar belakang container
          borderRadius: BorderRadius.circular(15), // Membulatkan sudut container
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status == 'pending'
                      ? 'Pending'
                      : status == 'confirmed'
                          ? 'Confirmed'
                          : status == 'completed'
                              ? 'Complete'
                              : 'Canceled',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Nama layanan
              Text(
                service,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Nama barber
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    'Barber: $barber',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Tanggal dan waktu
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    'Tanggal: $date',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    'Waktu: $time',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(dateTime);
  }
}