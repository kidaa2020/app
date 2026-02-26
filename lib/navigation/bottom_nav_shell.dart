import 'package:flutter/material.dart';
import 'package:healthbuddy/features/today/screens/today_screen.dart';
import 'package:healthbuddy/features/pet/screens/pet_screen.dart';
import 'package:healthbuddy/features/workout/screens/workout_list_screen.dart';
import 'package:healthbuddy/features/profile/screens/profile_screen.dart';

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TodayScreen(),
    PetScreen(),
    WorkoutListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.today),
                activeIcon: Icon(Icons.today, size: 28),
                label: 'Hoy',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pets),
                activeIcon: Icon(Icons.pets, size: 28),
                label: 'Mascota',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                activeIcon: Icon(Icons.fitness_center, size: 28),
                label: 'Entreno',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                activeIcon: Icon(Icons.person, size: 28),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
