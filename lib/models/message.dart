class MessageModel {
  final String id;
  final String senderId;
  final String senderRole;
  final String text;
  final DateTime createdAt;
  final List<String> seenBy;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.createdAt,
    required this.seenBy,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'],
      senderRole: map['senderRole'],
      text: map['text'],
      createdAt: map['createdAt'].toDate(),
      seenBy: List<String>.from(map['seenBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderRole': senderRole,
      'text': text,
      'createdAt': createdAt,
      'seenBy': seenBy,
    };
  }
}
