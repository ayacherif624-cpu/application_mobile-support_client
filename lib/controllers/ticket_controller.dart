 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ticket.dart';

class TicketController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Liste locale Admin & Support
  List<TicketModel> tickets = [];

  CollectionReference get _ticketsRef => _firestore.collection('tickets');

  // ============================================================
  // ✅ CREATE — Ajouter un ticket
  // ============================================================
  Future<void> ajouterTicket(TicketModel ticket) async {
    try {
      await _ticketsRef.add(ticket.toMap());
      await fetchAllTickets();
    } catch (e) {
      debugPrint("❌ Erreur ajout ticket: $e");
      rethrow;
    }
  }

  // ============================================================
  // ✅ READ — Tickets d’un utilisateur
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
      await fetchAllTickets();
    } catch (e) {
      debugPrint("❌ Erreur modification: $e");
      rethrow;
    }
  }

  // ============================================================
  // ✅ UPDATE — Changer statut (SUPPORT)
  // ============================================================
  Future<void> changerStatut({
    required String ticketId,
    required String nouveauStatut,
    required String roleUtilisateur,
  }) async {
    if (roleUtilisateur != 'support') {
      throw Exception("Seul le support peut modifier le statut");
    }

    try {
      await _ticketsRef.doc(ticketId).update({
        'status': nouveauStatut,
      });

      await fetchAllTickets();
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
      await fetchAllTickets();
    } catch (e) {
      debugPrint("❌ Erreur suppression: $e");
      rethrow;
    }
  }

  // ============================================================
  // ✅ ADMIN — Tous les tickets
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
  // ✅ ASSIGNATION — Affecter un support
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

      int index = tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        final old = tickets[index];

        tickets[index] = TicketModel(
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
      }

      notifyListeners();
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
}
