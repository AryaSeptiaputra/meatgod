import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; // Untuk mengatur opacity tulisan

  @override
  void initState() {
    super.initState();
    // Menampilkan tulisan dengan efek animasi
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0; // Mengubah opacity tulisan menjadi 1 setelah delay
      });
    });

    // Navigasi ke login screen setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Mengubah background menjadi abu-abu
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1), // Durasi animasi
          child: Text(
            'Meat God', // Ganti dengan teks
            style: const TextStyle(
              fontSize: 40, // Ukuran font tulisan
              fontWeight: FontWeight.bold, // Gaya font tebal
              color: Colors.black, // Warna teks
            ),
          ),
        ),
      ),
    );
  }
}
