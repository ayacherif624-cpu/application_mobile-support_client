import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// ✅ VIEWS
import 'views/Ticket_Details_View.dart';
import 'views/TicketsAAffecterView.dart';
import 'views/choisir_support_view.dart';
import 'views/login_screen.dart';
import 'views/registerView.dart';
import 'views/SupportHome_view.dart';
import 'views/create_ticket_screen.dart';
import 'views/home_client.dart';
import 'views/admin_dashboard.dart';
import 'views/admin_ticket_list.dart' hide AdminTicketListView;
import 'views/admin_stats_view.dart';

// ✅ CONTROLLERS
import 'controllers/ticket_controller.dart';
import 'controllers/auth_controller.dart';

// ✅ MODEL
import 'models/ticket.dart';

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

      // ✅ ROUTES SANS ARGUMENTS
      routes: {
        '/': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),

        '/client': (context) {
          final auth = Provider.of<AuthController>(context, listen: false);
          final user = auth.currentUser;
          if (user == null) return const LoginView();
          return HomeClient();
        },

        '/support': (context) {
          final auth = Provider.of<AuthController>(context, listen: false);
          final user = auth.currentUser;
          if (user == null) return const LoginView();
          return SupportHomeView(
            userId: user.uid,
            roleUtilisateur: user.role ?? 'support',
          );
        },

        '/admin': (context) {
          final auth = Provider.of<AuthController>(context, listen: false);
          final user = auth.currentUser;
          if (user == null) return const LoginView();
          return AdminDashboard(
            userId: user.uid,
            roleUtilisateur: user.role ?? 'admin',
          );
        },

        '/create-ticket': (context) {
          final auth = Provider.of<AuthController>(context, listen: false);
          final user = auth.currentUser;
          if (user == null) return const LoginView();
          return CreateTicketView(userId: user.uid);
        },

        '/support-admin-tickets': (context) => AdminTicketListView(),
        '/admin-stats': (context) => AdminStatsView(),
        '/tickets-a-affecter': (context) => const TicketsAAffecterView(),
        '/choisir-support': (context) => const ChoisirSupportView(),
      },

      // ✅✅✅ ROUTE AVEC ARGUMENTS PRIORITÉ (STABLE)
      onGenerateRoute: (settings) {
        if (settings.name == '/admin-priorites') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null ||
              !args.containsKey('ticket') ||
              !args.containsKey('roleUtilisateur')) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("❌ Aucun ticket fourni")),
              ),
            );
          }

          final TicketModel ticket = args['ticket'];
          final String roleUtilisateur = args['roleUtilisateur'];

          return MaterialPageRoute(
            builder: (_) => AdminTicketListView(
               
            ),
          );
        }

        return null;
      },
    );
  }
}
