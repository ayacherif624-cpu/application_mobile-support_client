 import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase/views/Support_Chats_view.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';

// VIEWS
import 'views/ticket_affecter_view.dart';
import 'views/Ticket_Details_View.dart';
import 'views/Tickets_AAffecter_View.dart';
import 'views/choisir_support_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/Support_Home_view.dart';
import 'views/create_ticket_view.dart';
import 'views/home_client_view.dart';
import 'views/admin_dashboard_view.dart';
import 'views/admin_ticket_list_view.dart';
import 'views/admin_stats_view.dart';

// CONTROLLERS
import 'controllers/ticket_controller.dart';
import 'controllers/auth_controller.dart';

// MODEL
import 'models/ticket_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔹 Mise à jour des tickets existants pour ajouter lastMessageTime si absent
  try {
    final snapshot = await FirebaseFirestore.instance.collection("tickets").get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (!data.containsKey("lastMessageTime")) {
        await doc.reference.update({"lastMessageTime": Timestamp.now()});
      }
    }
  } catch (e) {
    print("Erreur lors de la mise à jour des tickets : $e");
  }

  // 🔹 Initialiser les notifications locales
  await NotificationService.initialize();

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

      routes: {
        '/': (context) => const LoginView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/client': (context) => HomeClient(),

        '/support': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            return const Scaffold(
              body: Center(child: Text("❌ Utilisateur non connecté")),
            );
          }
          return SupportHomeView(userId: user.uid, roleUtilisateur: 'support');
        },

        '/SupportTicketsView': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            return const Scaffold(
              body: Center(child: Text("❌ Utilisateur non connecté")),
            );
          }
          return SupportTicketsView(supportId: user.uid);
        },

        '/support-chats': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            return const Scaffold(
              body: Center(child: Text("❌ Utilisateur non connecté")),
            );
          }
          return SupportChatsView(supportId: user.uid);
        },

        '/admin': (context) => const AdminDashboard(userId: '', roleUtilisateur: 'admin'),
        '/create-ticket': (context) => const CreateTicketView(userId: ''),
        '/support-admin-tickets': (context) => const AdminTicketListView(),
        '/admin-stats': (context) => AdminStatsView(),
        '/tickets-a-affecter': (context) => const TicketsAAffecterView(),
        '/choisir-support': (context) => const ChoisirSupportView(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/admin-priorites') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null || !args.containsKey('ticket') || !args.containsKey('roleUtilisateur')) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("❌ Arguments invalides")),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (_) => DetailTicketAdminView(
              ticket: args['ticket'],
              roleUtilisateur: args['roleUtilisateur'],
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("❌ Route inconnue")),
          ),
        );
      },
    );
  }
}
