 import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  String? id;
  String title;
  String description;
  String priority; 
  String category; 
  String status;   // ⚠️ nom correct du champ
  List<String> attachments; 
  String userId;
  Timestamp createdAt;

  TicketModel({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    this.status = "Nouveau",  // valeur par défaut
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

  // Convertir depuis un Map de Firestore
  factory TicketModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return TicketModel(
      id: id ?? map['id'], 
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

  // Méthode pour changer le statut côté support
  void changerStatut(String nouveauStatut) {
    status = nouveauStatut;  // ✅ correction du nom de champ
  }
   // 🔹 copyWith : pour modifier certains champs sans recréer l’objet
  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? category,
    String? status,
    List<String>? attachments,
    String? userId,
    String? assignedTo,
    Timestamp? createdAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      userId: userId ?? this.userId,
       
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

