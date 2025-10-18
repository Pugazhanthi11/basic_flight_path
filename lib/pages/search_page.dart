// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final fromCtrl = TextEditingController();
  final toCtrl = TextEditingController();

  Future<List<String>> _getSuggestions(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
    final res = await http.get(url, headers: {'User-Agent': 'flutter-flight-app'});
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data.map<String>((e) => e['display_name'] as String).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg3.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.4)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Find Your Flight Route",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Departure Field
                TypeAheadField<String>(
                  controller: fromCtrl,
                  suggestionsCallback: _getSuggestions,
                  itemBuilder: (context, suggestion) {
                    return ListTile(title: Text(suggestion));
                  },
                  onSelected: (suggestion) {
                    fromCtrl.text = suggestion;
                  },
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: _buildInput("Departure City / Country"),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Destination Field
                TypeAheadField<String>(
                  controller: toCtrl,
                  suggestionsCallback: _getSuggestions,
                  itemBuilder: (context, suggestion) {
                    return ListTile(title: Text(suggestion));
                  },
                  onSelected: (suggestion) {
                    toCtrl.text = suggestion;
                  },
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: _buildInput("Destination City / Country"),
                    );
                  },
                ),

                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    if (fromCtrl.text.isEmpty || toCtrl.text.isEmpty) return;
                    Navigator.pushNamed(
                      context,
                      '/map',
                      arguments: {'from': fromCtrl.text, 'to': toCtrl.text},
                    );
                  },
                  icon: const Icon(Icons.flight_takeoff),
                  label: const Text("Show Route"),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
