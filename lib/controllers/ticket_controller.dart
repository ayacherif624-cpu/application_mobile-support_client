 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ticket_model.dart';

class TicketController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _ticketsRef => _firestore.collection('tickets');

  // ======================
  // 🔹 CREATE - Ajouter un ticket
  // ======================
  Future<void> ajouterTicket(TicketModel ticket) async {
    try {
      await _ticketsRef.add(ticket.toMap());
      notifyListeners();
    } catch (e) {
      throw 'Erreur lors de l\'ajout du ticket: $e';
    }
  }

  // ======================
  // 🔹 READ - Récupérer tous les tickets d’un utilisateur (stream)
  // ======================
  Stream<List<TicketModel>> getTicketsParUtilisateur(String userId) {
    return _ticketsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                TicketModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
 

  

  // ======================
  // 🔹 UPDATE - Modifier un ticket
  // ======================
  Future<void> modifierTicket(String ticketId, TicketModel ticket) async {
    try {
      await _ticketsRef.doc(ticketId).update(ticket.toMap());
      notifyListeners();
    } catch (e) {
      throw 'Erreur lors de la modification du ticket: $e';
    }
  }
 

  // ======================
  // 🔹 DELETE - Supprimer un ticket
  // ======================
  Future<void> supprimerTicket(String ticketId) async {
    try {
      await _ticketsRef.doc(ticketId).delete();
      notifyListeners();
    } catch (e) {
      throw 'Erreur lors de la suppression du ticket: $e';
    }
  }

   

}
