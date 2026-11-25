import 'package:flutter/material.dart';

void main() {
  runApp(const GestorAgendaApp());
}

/// Root widget for the Gestor de Agenda application.
class GestorAgendaApp extends StatelessWidget {
  const GestorAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Agenda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Gestor de Agenda'),
        ),
      ),
    );
  }
}
