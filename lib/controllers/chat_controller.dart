import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Envoyer un message
  Future<void> sendMessage({
    required String ticketId,
    required MessageModel message,
  }) async {
    await _firestore
        .collection('tickets')
        .doc(ticketId)
        .collection('messages')
        .add(message.toMap());
  }

  // ✅ Lire messages en temps réel
  Stream<List<MessageModel>> getMessages(String ticketId) {
    return _firestore
        .collection('tickets')
        .doc(ticketId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  MessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ✅ Marquer messages comme vus
  Future<void> markAsSeen(
      String ticketId, String messageId, String userId) async {
    final ref = _firestore
        .collection('tickets')
        .doc(ticketId)
        .collection('messages')
        .doc(messageId);

    await ref.update({
      'seenBy': FieldValue.arrayUnion([userId])
    });
  }
}
