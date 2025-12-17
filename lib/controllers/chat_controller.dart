import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../services/notification_service.dart'; // Assure-toi d’avoir ce fichier

class ChatController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Stream des messages d’un ticket
  Stream<List<MessageModel>> getMessages(String ticketId) {
    return firestore
        .collection("tickets")
        .doc(ticketId)
        .collection("messages")
        .orderBy("createdAt")
        .snapshots()
        .map((query) =>
            query.docs.map((doc) => MessageModel.fromMap(doc.id, doc.data())).toList());
  }

  /// Envoyer un message
  Future<void> sendMessage({
    required String ticketId,
    required MessageModel message,
  }) async {
    final messageRef = firestore
        .collection("tickets")
        .doc(ticketId)
        .collection("messages")
        .doc();

    await messageRef.set(message.toMap());

    // Incrémenter le compteur "non lu" pour l’autre rôle
    String otherRole = message.senderRole == "client" ? "support" : "client";
    await firestore.collection("tickets").doc(ticketId).update({
      "${otherRole}_unread": FieldValue.increment(1),
      "lastMessage": message.text,
      "lastMessageTime": FieldValue.serverTimestamp(),
    });
  }

  /// Marquer un message comme lu
  Future<void> markAsSeen({
    required String ticketId,
    required String messageId,
    required String userId,
  }) async {
    await firestore
        .collection("tickets")
        .doc(ticketId)
        .collection("messages")
        .doc(messageId)
        .update({
      'seenBy': FieldValue.arrayUnion([userId]),
    });
  }

  /// Stream des messages avec notification pour les nouveaux messages
  Stream<List<MessageModel>> getMessagesWithNotification(
      String ticketId, String currentUserId) {
    return firestore
        .collection("tickets")
        .doc(ticketId)
        .collection("messages")
        .orderBy("createdAt")
        .snapshots()
        .map((query) {
      final messages = query.docs
          .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
          .toList();

      // Vérifier le dernier message pour envoyer notification
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;

        // Si le message est envoyé par l'autre rôle et non encore lu
        if (lastMessage.senderId != currentUserId &&
            !(lastMessage.seenBy.contains(currentUserId))) {
          NotificationService.showNotification(
            title: "Nouveau message",
            body: lastMessage.text,
          );
        }
      }

      return messages;
    });
  }
}
