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
import 'views/admin_ticket_list.dart';
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
      initialRoute: '/',

      // ✅ ROUTES SANS ARGUMENTS
      routes: {
        '/': (context) => const LoginView(),
         '/login': (context) => LoginView(),
        '/register': (context) => const RegisterView(),
        '/client': (context) => HomeClient(),
        '/support': (context) => const SupportHomeView(

              userId: '',
              roleUtilisateur: 'support',
            ),
        '/admin': (context) => const AdminDashboard(
              userId: '',
              roleUtilisateur: 'admin',
            ),
        '/create-ticket': (context) => const CreateTicketView(userId: ''),
        '/login': (context) => LoginView(),
        '/support-admin-tickets': (context) => const AdminTicketListView(),
        '/admin-stats': (context) => AdminStatsView(),
        '/tickets-a-affecter': (context) => const TicketsAAffecterView(),
        '/choisir-support': (context) => const ChoisirSupportView(),
      },

      // ✅✅✅ ROUTE AVEC ARGUMENTS (DETAIL TICKET ADMIN)
      onGenerateRoute: (settings) {
        if (settings.name == '/admin-priorites') {
          print("✅ Route /admin-priorites appelée");
          print("📦 Arguments reçus : ${settings.arguments}");

          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null ||
              !args.containsKey('ticket') ||
              !args.containsKey('roleUtilisateur')) {
            print("❌ ERREUR : arguments invalides");
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("❌ Aucun ticket fourni")),
              ),
            );
          }

          final TicketModel ticket = args['ticket'];
          final String roleUtilisateur = args['roleUtilisateur'];

          print("✅ Ticket reçu : ${ticket.titre}");
          print("✅ Rôle reçu : $roleUtilisateur");

          return MaterialPageRoute(
            builder: (_) => DetailTicketAdminView(
              ticket: ticket,
              roleUtilisateur: roleUtilisateur,
            ),
          );
        }

        return null;
      },
    );
  }
}
