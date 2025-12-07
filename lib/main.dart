import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase/views/TicketsAAffecterView.dart';
 
import 'package:flutter_firebase/views/choisir_support_view.dart';
import 'package:provider/provider.dart';

// ✅ AUTH
import 'views/login_screen.dart';
import 'views/registerView.dart';

// ✅ CLIENT & SUPPORT
import 'views/SupportHome_view.dart';
import 'views/ticket_list_screen.dart';
import 'views/create_ticket_screen.dart';
import 'views/home_client.dart';

// ✅ ADMIN
import 'views/admin_dashboard.dart';
import 'views/admin_ticket_list.dart';
import 'views/admin_users_view.dart';
import 'views/admin_stats_view.dart';

// ✅ CONTROLLERS
import 'controllers/ticket_controller.dart';
import 'controllers/auth_controller.dart';

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
        // ✅ AUTH
        '/': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),

        // ✅ CLIENT
        '/client': (context) {
          final authController =
              Provider.of<AuthController>(context, listen: false);
          final user = authController.currentUser;
          if (user == null) return const LoginView();
          return HomeClient();
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

        // ✅ CREATION TICKET
        '/create-ticket': (context) {
          final authController =
              Provider.of<AuthController>(context, listen: false);
          final user = authController.currentUser;
          if (user == null) return const LoginView();
          return CreateTicketView(userId: user.uid);
        },

        // ✅ ADMIN ROUTES
        '/support-admin-tickets': (context) => AdminTicketListView(),
        '/users-management': (context) => AdminUsersView(),
        '/admin-stats': (context) => AdminStatsView(),
        '/tickets-a-affecter': (context) => const TicketsAAffecterView(),

        // ✅ ✅ ✅ ROUTE AFFECTATION TICKET (CORRIGÉE)
         '/choisir-support': (context) => const ChoisirSupportView(),
      },
    );
  }
}
