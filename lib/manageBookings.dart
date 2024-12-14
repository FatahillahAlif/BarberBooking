import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/bookingModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ManageBookingsPage extends StatefulWidget {
  const ManageBookingsPage({super.key});

  @override
  State<ManageBookingsPage> createState() => _ManageBookingsPageState();
}

class _ManageBookingsPageState extends State<ManageBookingsPage> {
  String selectedCategory = 'Pending';
  List<Booking> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  // Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi untuk mengambil data bookings dari API
  Future<void> fetchBookings() async {
    try {
      final String token = await getToken() ?? '';
      final url = Uri.parse('http://10.0.2.2:3000/booking/');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['bookings'];
        setState(() {
          bookings = data.map((json) => Booking.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load bookings: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> updateBookingStatus(int bookingId, String newStatus) async {
    try {
      final String token = await getToken() ?? '';
      final url = Uri.parse('http://10.0.2.2:3000/booking/status/$bookingId');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          bookings = bookings.map((booking) {
            if (booking.id == bookingId) {
              return booking.copyWith(status: newStatus);
            }
            return booking;
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully!')),
        );
      } else {
        throw Exception('Failed to update status: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  // Memfilter booking berdasarkan kategori status
  List<Booking> filterBookingsByStatus(String status) {
    return bookings.where((booking) {
      if (status == 'Pending') {
        return booking.status == 'pending';
      } else if (status == 'Confirm') {
        return booking.status == 'confirmed';
      } else if (status == 'Complete') {
        return booking.status == 'completed';
      } else {
        return booking.status == 'cancelled';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ToggleButtons untuk kategori status
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
                    child: ListView.builder(
                      itemCount: filterBookingsByStatus(selectedCategory).length,
                      itemBuilder: (context, index) {
                        final booking = filterBookingsByStatus(selectedCategory)[index];
                        final formattedDate = DateFormat('dd MMM yyyy').format(booking.bookingDate);
                        return bookingCard(
                          booking,
                          formattedDate,
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget bookingCard(Booking booking, String formattedDate) {
    Color statusColor;
    Color cardColor;

    // Tentukan warna berdasarkan status
    if (booking.status == 'pending') {
      statusColor = Colors.orangeAccent;
      cardColor = Colors.orange[50]!;
    } else if (booking.status == 'confirmed') {
      statusColor = Colors.blueAccent;
      cardColor = Colors.blue[50]!;
    } else if (booking.status == 'completed') {
      statusColor = Colors.greenAccent;
      cardColor = Colors.green[50]!;
    } else {
      statusColor = Colors.redAccent;
      cardColor = Colors.red[50]!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barber: ${booking.barber.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('User: ${booking.user.fullName}'),
            Text('Service: ${booking.service.name}'),
            Text('Date: $formattedDate'),
            Text('Time: ${booking.bookingTime}'),
            Text(
              'Status: ${booking.status}',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () {
                    if (booking.status != 'confirmed') {
                      updateBookingStatus(booking.id, 'confirmed');
                    }
                  },
                  child: const Text('Confirm', style: TextStyle(color: Colors.white),),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                  onPressed: () {
                    if (booking.status != 'completed') {
                      updateBookingStatus(booking.id, 'completed');
                    }
                  },
                  child: const Text('Complete', style: TextStyle(color:Colors.white),),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    if (booking.status != 'cancelled') {
                      updateBookingStatus(booking.id, 'cancelled');
                    }
                  },
                  child: const Text('Cancel', style: TextStyle(color:Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}