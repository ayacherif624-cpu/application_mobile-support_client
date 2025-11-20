 import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  String? id;
  String title;
  String description;
  String priority; // ex: "Faible", "Moyenne", "Haute"
  String category; // ex: "Technique", "Comptabilité", etc.
  String status;   // ex: "Nouveau", "En cours", "Résolu"
  List<String> attachments; // URLs des fichiers/images
  String userId;
  Timestamp createdAt;

  TicketModel({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    this.status = "Nouveau",
    this.attachments = const [],
    required this.userId,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      'status': status,
      'attachments': attachments,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

   factory TicketModel.fromMap(Map<String, dynamic> map, [String? id]) {
  return TicketModel(
    id: id ?? map['id'], // si id passé, on l'utilise sinon on prend map['id']
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    priority: map['priority'] ?? 'Faible',
    category: map['category'] ?? '',
    status: map['status'] ?? 'Nouveau',
    attachments: map['attachments'] != null
        ? List<String>.from(map['attachments'])
        : [],
    userId: map['userId'] ?? '',
    createdAt: map['createdAt'] != null
        ? (map['createdAt'] is Timestamp
            ? map['createdAt']
            : Timestamp.fromDate(DateTime.parse(map['createdAt'])))
        : Timestamp.now(),
  );
}


}
