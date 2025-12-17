import 'package:flutter/material.dart';
import '../controllers/chat_controller.dart';
import '../models/message_model.dart';
import '../services/notification_service.dart';

class ChatView extends StatefulWidget {
  final String ticketId;
  final String currentUserId;
  final String userRole; // "client" ou "support"

  const ChatView({
    super.key,
    required this.ticketId,
    required this.currentUserId,
    required this.userRole,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ChatController chatController = ChatController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Discussion")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatController.getMessages(widget.ticketId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                // Notifications pour les nouveaux messages
                if (messages.isNotEmpty) {
                  final lastMessage = messages.last;
                  if (lastMessage.senderId != widget.currentUserId &&
                      !(lastMessage.seenBy?.contains(widget.currentUserId) ?? false)) {
                    NotificationService.showNotification(
                      title: "Nouveau message",
                      body: lastMessage.text,
                    );
                  }
                }

                if (messages.isEmpty) {
                  return const Center(child: Text("Aucun message."));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isMe ? Colors.white70 : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Écrire un message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = MessageModel(
      id: "",
      senderId: widget.currentUserId,
      senderRole: widget.userRole,
      text: text,
      createdAt: DateTime.now(),
      seenBy: [widget.currentUserId],
    );

    chatController.sendMessage(ticketId: widget.ticketId, message: message);
    _controller.clear();

    // Scroll vers le bas
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
