 import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase/views/admin_dashboard.dart';
import 'package:provider/provider.dart';

// Views
import 'views/login_screen.dart';
import 'views/registerView.dart';
import 'views/SupportHome_view.dart';
import 'views/ticket_list_screen.dart';
import 'views/create_ticket_screen.dart';

import 'views/home_client.dart'; // ✅ AJOUT IMPORTANT

// Controllers
import '../controllers/ticket_controller.dart';
import '../controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
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
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),

        // ✅ CLIENT → HOME CLIENT
        '/client': (context) {
          final authController =
              Provider.of<AuthController>(context, listen: false);
          final user = authController.currentUser;
          if (user == null) return const LoginView();
          return HomeClient(); // ✅ CORRIGÉ
        },

        // ✅ SUPPORT
        '/support': (context) {
          final authController =
              Provider.of<AuthController>(context, listen: false);
          final user = authController.currentUser;
          if (user == null) return const LoginView();
          return SupportHomeView(
            userId: user.uid,
            roleUtilisateur: user.role ?? 'support',
          );
        },

        // ✅ ADMIN
        '/admin': (context) {
          final authController =
              Provider.of<AuthController>(context, listen: false);
          final user = authController.currentUser;
          if (user == null) return const LoginView();
          return AdminDashboard(
            userId: user.uid,
            roleUtilisateur: user.role ?? 'admin',
          );
        },

        // ✅ CRÉER TICKET
        '/create-ticket': (context) {
          final authController =
              Provider.of<AuthController>(context, listen: false);
          final user = authController.currentUser;
          if (user == null) return const LoginView();
          return CreateTicketView(userId: user.uid);
        },
      },
    );
  }
}
