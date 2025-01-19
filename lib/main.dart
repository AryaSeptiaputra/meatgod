  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:meatgod/firebase_options.dart';
import 'package:meatgod/navbarAdmin.dart';
  import 'package:meatgod/navbarUser.dart';
  import 'package:meatgod/screens/auth/login_screen.dart';
  import 'package:meatgod/screens/auth/registration_screen.dart';

  // Import screens
  import 'screens/splash_screen.dart'; // Pastikan path sesuai dengan struktur proyek Anda

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Meat God',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Menghilangkan debug banner
        debugShowCheckedModeBanner: false,
        // Mendefinisikan routes
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/navbarUser':(context) => const NavbarUser(),
          '/navbarAdmin':(context) => const NavbarAdmin(),
        },
      );
    }
  }
