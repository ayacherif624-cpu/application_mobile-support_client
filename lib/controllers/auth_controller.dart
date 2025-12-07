 import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? currentUser; // ✅ Utilisateur connecté en mémoire

  // =====================================================
  // ✅ CONNEXION
  // =====================================================
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        currentUser =
            UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        // ✅ Enregistrer le TOKEN FCM après login
        await saveFcmTokenForCurrentUser();

        notifyListeners();
        return currentUser;
      }
    } catch (e) {
      debugPrint("Erreur login: $e");
    }
    return null;
  }

  // =====================================================
  // ✅ GETTERS
  // =====================================================
  String? get uid => currentUser?.uid;
  String? get role => currentUser?.role;

  // =====================================================
  // ✅ DÉCONNEXION
  // =====================================================
  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners();
  }

  // =====================================================
  // ✅ FCM : ENREGISTRER LE TOKEN POUR NOTIFICATIONS
  // =====================================================
  Future<void> saveFcmTokenForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();

    if (token != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    }

    // ✅ Écoute automatique si le token change
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _firestore.collection('users').doc(user.uid).update({
        'fcmToken': newToken,
      });
    });
  }
}
