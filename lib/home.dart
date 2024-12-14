import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'profilepage.dart';
import 'bookinghistory.dart';
import 'booking.dart';
import 'barberDetail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String username = ''; // Variabel untuk menyimpan username

  static const List<Widget> _widgetOptions = <Widget>[
    BarberListPage(), // Main Home Page (Grid of Barbers)
    BookingBarberPage(), // Booking Page
    HistoryBookingPage(), // History Booking Page
    ProfilePage(), // Profile Page
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Memuat username saat halaman pertama kali dibuka
  }

  // Fungsi untuk memuat username dari SharedPreferences
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }
  

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Kelas terpisah untuk bagian grid barber
class BarberListPage extends StatefulWidget {
  const BarberListPage({super.key});

  @override
  State<BarberListPage> createState() => _BarberListPageState();
}

class _BarberListPageState extends State<BarberListPage> {
  // Barber data dari backend
  List<Map<String, dynamic>> barberShops = [];

  // Data services dari backend
  List<Map<String, dynamic>> services = [];

  // Variabel untuk menyimpan segment yang dipilih
  int _selectedSegment = 0;

  @override
  void initState() {
    super.initState();
    _fetchBarbers(); // Memanggil fungsi untuk mengambil data barber dari API
    _fetchServices(); // Memanggil fungsi untuk mengambil data services dari API
  }

  // Fungsi untuk mengambil data barber dari API
  Future<void> _fetchBarbers() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found!');
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/barber'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        barberShops = (data['barbers'] as List).map((barber) {
          final scheduleList = (barber['schedules'] as List)
              .map((s) => '${s['day_of_week']}: ${s['start_time']} - ${s['end_time']}')
              .toList();

          return {
            'name': barber['name'],
            'position': barber['position'],
            'image': barber['image_url'],
            'description': barber['description'],
            'schedule': scheduleList.isNotEmpty ? scheduleList.join('\n') : 'No schedule available',
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load barbers');
    }
  }

  // Fungsi untuk mengambil data services dari API
  Future<void> _fetchServices() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found!');
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/service/services'), // Ganti URL ini sesuai API untuk services
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        services = (data['services'] as List).map((service) {
          return {
            'name': service['name'],
            'price': service['price'],
            'description': service['description'],
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load services');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _loadUsername(), // Memanggil fungsi untuk memuat username
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Menunggu username dimuat
              }

              if (snapshot.hasError) {
                return const Text('Error loading username');
              }

              final username = snapshot.data ?? 'User';
              return Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10, right: 16, left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hello, $username! 👋',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/Barbershop.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/booking');
                    },
                    child: const Text(
                      'Booking Now',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment<int>(
                    value: 0,
                    label: Text(
                      'Our Barber',
                      style: TextStyle(
                        color: _selectedSegment == 0 ? Colors.white : Colors.black,
                      ),
                    ),
                    icon: Icon(
                      Icons.person,
                      color: _selectedSegment == 0 ? Colors.white : Colors.black,
                    ),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    label: Text(
                      'Our Services',
                      style: TextStyle(
                        color: _selectedSegment == 1 ? Colors.white : Colors.black,
                      ),
                    ),
                    icon: Icon(
                      Icons.work,
                      color: _selectedSegment == 1 ? Colors.white : Colors.black,
                    ),
                  ),
                ],
                selected: {_selectedSegment},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedSegment = newSelection.first;
                  });
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.black; // Warna tombol saat dipilih
                      }
                      return Colors.grey[300]!; // Warna tombol saat tidak dipilih
                    },
                  ),
                ),
              ),
            ),
          ),

          // Menampilkan Barber atau Services berdasarkan segmen yang dipilih
          _selectedSegment == 0 ? _buildBarberGrid() : _buildServicesList(),
        ],
      ),
    );
  }

  // Fungsi untuk memuat username dari SharedPreferences
  Future<String> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'User'; // Ambil username atau 'User' jika tidak ada
  }

  String baseUrl = 'http://10.0.2.2:3000';

  Widget _buildBarberGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2 / 3,
        ),
        itemCount: barberShops.length,
        itemBuilder: (context, index) {
          final barberShop = barberShops[index];
          String imageUrl = baseUrl + barberShop['image'];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarberDetailPage(
                    name: barberShop['name'],
                    position: barberShop['position'],
                    image: imageUrl,
                    description: barberShop['description'],
                    schedule: barberShop['schedule'],
                  ),
                ),
              );
            },
            child: Card(
              color: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      barberShop['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Text(
                    barberShop['position'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Fungsi untuk menampilkan list of services dengan style yang diinginkan
  Widget _buildServicesList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];

          int price = int.tryParse(service['price'].toString()) ?? 0;
          String formatPrice(int price) {
            String priceStr = price.toString();
            String formattedPrice = priceStr.substring(0, priceStr.length - 3);
            return 'Rp. $formattedPrice K';
          }

          return Card(
            color: Colors.black, // Ubah warna card menjadi hitam
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                service['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // Ubah warna teks menjadi putih
              ),
              subtitle: Text(
                service['description'],
                style: const TextStyle(color: Colors.white70), // Ubah warna teks menjadi putih keabu-abuan
              ),
              trailing: Text(
                formatPrice(price),
                style: const TextStyle(fontSize: 16, color: Colors.white), // Ubah warna teks menjadi putih
              ),
            ),
          );
        },
      ),
    );
  }
}
