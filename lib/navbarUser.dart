import 'package:flutter/material.dart';
import 'package:meatgod/screens/user/home_screen.dart';

class NavbarUser extends StatefulWidget {
  const NavbarUser({super.key});

  @override
  _NavbarUserState createState() => _NavbarUserState();
}

class _NavbarUserState extends State<NavbarUser> {
  int _currentIndex = 0;

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF636363),
              const Color(0xFF737373)         ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            height: 1.5,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            height: 1.5,
          ),
          selectedIconTheme: IconThemeData(
            size: 28,
            opacity: 1,
          ),
          unselectedIconTheme: IconThemeData(
            size: 24,
            opacity: 0.6,
          ),
          mouseCursor: MaterialStateMouseCursor.clickable,
          items: [
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(_currentIndex == 0 ? 8.0 : 4.0),
                decoration: BoxDecoration(
                  color: _currentIndex == 0
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.home_rounded),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(_currentIndex == 1 ? 8.0 : 4.0),
                decoration: BoxDecoration(
                  color: _currentIndex == 1
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shopping_cart_rounded),
              ),
              label: 'Orders',
            ),  
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(_currentIndex == 3 ? 8.0 : 4.0),
                decoration: BoxDecoration(
                  color: _currentIndex == 3
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_rounded),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
