 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ticket.dart';

class TicketController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TicketModel> tickets = [];

  CollectionReference get _ticketsRef => _firestore.collection('tickets');

  // ============================================================
  // ✅ CREATE — Ajouter un ticket
  // ============================================================
  Future<void> ajouterTicket(TicketModel ticket) async {
    try {
      await _ticketsRef.add(ticket.toMap());
    } catch (e) {
      debugPrint("❌ Erreur ajout ticket: $e");
      rethrow;
    }
  }

  // ============================================================
  // ✅ READ — Tickets d’un utilisateur (STREAM)
  // ============================================================
  Stream<List<TicketModel>> getTicketsParUtilisateur(String userId) {
    return _ticketsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TicketModel.fromDoc(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // ============================================================
  // ✅ UPDATE — Modifier ticket
  // ============================================================
  Future<void> modifierTicket(String ticketId, TicketModel ticket) async {
    try {
      await _ticketsRef.doc(ticketId).update(ticket.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Erreur modification: $e");
      rethrow;
    }
  }

  // ============================================================
  // ✅ UPDATE — Changer statut (support ET admin)
  // ============================================================
  Future<void> changerStatut({
    required String ticketId,
    required String nouveauStatut,
    required String roleUtilisateur,
  }) async {
    // Autoriser admin et support
    if (roleUtilisateur != 'support' && roleUtilisateur != 'admin') {
      throw Exception("Seul le support ou l'admin peut modifier le statut");
    }

    try {
      await _ticketsRef.doc(ticketId).update({
        'status': nouveauStatut,
      });

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Erreur changement statut: $e");
      rethrow;
    }
  }

  // ============================================================
  // ✅ DELETE — Supprimer ticket
  // ============================================================
  Future<void> supprimerTicket(String ticketId) async {
    try {
      await _ticketsRef.doc(ticketId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Erreur suppression: $e");
      rethrow;
    }
  }

  // ============================================================
  // ✅ ADMIN — Tous les tickets (CHARGEMENT MANUEL)
  // ============================================================
  Future<void> fetchAllTickets() async {
    try {
      final query = await _ticketsRef
          .orderBy('createdAt', descending: true)
          .get();

      tickets = query.docs.map((doc) {
        return TicketModel.fromDoc(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Erreur récupération tickets: $e");
    }
  }

  // ============================================================
  // ✅ ASSIGNATION CORRECTE & STABLE
  // ============================================================
  Future<void> assignTicket({
    required String ticketId,
    required String supportId,
  }) async {
    try {
      await _ticketsRef.doc(ticketId).update({
        'assignerId': supportId,
        'status': 'En cours',
      });

      // Mettre à jour la liste locale si présente
      final idx = tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) {
        final old = tickets[idx];
        tickets[idx] = TicketModel(
          id: old.id,
          titre: old.titre,
          description: old.description,
          priorite: old.priorite,
          categorie: old.categorie,
          status: 'En cours',
          userId: old.userId,
          assignerId: supportId,
          attachments: old.attachments,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Erreur assignation: $e");
      rethrow;
    }
  }

  // ============================================================
  // ✅ CHAT — ENVOYER MESSAGE
  // ============================================================
  Future<void> envoyerMessage({
    required String ticketId,
    required String senderId,
    required String senderRole,
    required String text,
  }) async {
    try {
      await _ticketsRef
          .doc(ticketId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'senderRole': senderRole,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'attachments': [],
        'seenBy': [senderId],
      });
    } catch (e) {
      debugPrint("❌ Erreur envoi message: $e");
      rethrow;
    }
  }

  // ============================================================
  // ✅ CHAT — STREAM DES MESSAGES
  // ============================================================
  Stream<QuerySnapshot> getMessages(String ticketId) {
    return _ticketsRef
        .doc(ticketId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  // ============================================================
  // ✅ CHAT — MESSAGE VU
  // ============================================================
  Future<void> marquerCommeVu({
    required String ticketId,
    required String messageId,
    required String userId,
  }) async {
    try {
      await _ticketsRef
          .doc(ticketId)
          .collection('messages')
          .doc(messageId)
          .update({
        'seenBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint("❌ Erreur message vu: $e");
    }
  }

  // ============================================================
  // ✅ ADMIN — Modifier la priorité
  // ============================================================
  Future<void> changerPriorite({
    required String ticketId,
    required String nouvellePriorite,
    required String roleUtilisateur,
  }) async {
    if (roleUtilisateur != 'admin') {
      throw Exception("Seul l'admin peut modifier la priorité");
    }

    try {
      await _ticketsRef.doc(ticketId).update({
        'priorite': nouvellePriorite,
      });

      // Optionnel : mettre à jour la copie locale si chargée
      final idx = tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) {
        final old = tickets[idx];
        tickets[idx] = TicketModel(
          id: old.id,
          titre: old.titre,
          description: old.description,
          priorite: nouvellePriorite,
          categorie: old.categorie,
          status: old.status,
          userId: old.userId,
          assignerId: old.assignerId,
          attachments: old.attachments,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Erreur changement priorité: $e");
      rethrow;
    }
  }

  // ============================================================
  // ✅ STREAM — Tous les tickets (pour la liste admin)
  // ============================================================
  Stream<List<TicketModel>> getTousLesTickets() {
    return _ticketsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TicketModel.fromDoc(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }
}
