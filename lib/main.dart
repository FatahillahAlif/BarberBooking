import 'package:barberbooking/booking.dart';
import 'package:barberbooking/bookinghistory.dart';
import 'package:barberbooking/editprofile.dart';
import 'package:barberbooking/manageBarbers.dart';
import 'package:barberbooking/manageBookings.dart';
import 'package:barberbooking/manageUsers.dart';
import 'package:barberbooking/manageService.dart';
import 'package:barberbooking/security.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'forgetpass.dart';
import 'authentication.dart';
import 'home.dart';
import 'profilepage.dart';
import 'adminHomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarberBooking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Satoshi',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => RegisterPage(),
        '/forgetPassword': (context) => const ForgetPasswordPage(),
        '/authentication': (context) => const AuthenticationPage(),
        '/profile': (context) => const ProfilePage(),
        '/security': (context) => const SecurityPage(),
        '/editprofile': (context) => const EditProfile(),
        '/booking': (context) => const BookingBarberPage(),
        '/history': (context) => const HistoryBookingPage(),
        
        // Rute Admin
        '/adminHome': (context) => const AdminHomePage(),
        '/adminManageUsers': (context) => const ManageUsersPage(),
        '/adminManageBarbers': (context) => const ManageBarbersPage(),
        '/adminManageBookings': (context) => const ManageBookingsPage(),
        '/adminManageServices': (context) => const ManageServicesPage(),
      },
    );
  }
}
