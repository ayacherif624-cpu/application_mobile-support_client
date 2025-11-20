 import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // <- Ajouter Provider
import 'package:flutter_firebase/views/liste_tickets_view.dart';
import 'views/login_view.dart';
import 'views/create_ticket_view.dart';
import 'views/support_home_view.dart';
import '../controllers/ticket_controller.dart'; // <- Importer le controller

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TicketController()),
      ],
      child: const DevMobSupportClientApp(),
    ),
  );
}

class DevMobSupportClientApp extends StatelessWidget {
  const DevMobSupportClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEVMOB SUPPORTCLIENT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelStyle: TextStyle(color: Colors.blue),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/client': (context) => ListeTicketsView(userId: '1'),
        '/support': (context) => SupportHomeView(),
      },
    );
  }
}
