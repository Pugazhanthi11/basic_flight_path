import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/search_page.dart';
import 'pages/map_page.dart';

void main() {
  runApp(const FlightPathApp());
}

class FlightPathApp extends StatelessWidget {
  const FlightPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Path Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/search': (context) => const SearchPage(),
        '/map': (context) => const MapPage(),
      },
    );
  }
}
