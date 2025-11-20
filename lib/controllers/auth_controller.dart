 // controllers/auth_controller.dart
import '../models/user_model.dart';

class AuthController {
  // Simuler une connexion (normalement tu utiliserais Firebase / API)
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // simuler chargement

    // Exemple simple de validation
    if (email == 'client@test.com' && password == '123456') {
      return UserModel(id: '1', email: email, role: 'client');
    } else if (email == 'support@test.com' && password == '123456') {
      return UserModel(id: '2', email: email, role: 'support');
    } else {
      return null; // Email ou mot de passe incorrect
    }
  }
}
