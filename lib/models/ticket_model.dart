 class TicketModel {
  final String? id;
  final String titre;
  final String description;
  final String priorite;
  final String categorie;
  final String status;
  final String userId;
  final String? assignerId; // ✅ NOUVEAU
  final List<String> attachments;
  final DateTime createdAt;

  TicketModel({
    this.id,
    required this.titre,
    required this.description,
    required this.priorite,
    required this.categorie,
    required this.status,
    required this.userId,
    this.assignerId, // ✅ NOUVEAU
    required this.attachments,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'priorite': priorite,
      'categorie': categorie,
      'status': status,
      'userId': userId,
      'assignerId': assignerId, // ✅ SAUVEGARDE
      'attachments': attachments,
      'createdAt': createdAt,
    };
  }

  factory TicketModel.fromDoc(String id, Map<String, dynamic> data) {
    return TicketModel(
      id: id,
      titre: data['titre'],
      description: data['description'],
      priorite: data['priorite'],
      categorie: data['categorie'],
      status: data['status'],
      userId: data['userId'],
      assignerId: data['assignerId'], // ✅ RÉCUPÉRATION
      attachments: List<String>.from(data['attachments']),
      createdAt: data['createdAt'].toDate(),
    );
  }
}
