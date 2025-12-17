 import 'package:flutter/material.dart';
import '../controllers/chat_controller.dart';
import '../models/message_model.dart';
import '../services/notification_service.dart';

class ChatView extends StatefulWidget {
  final String ticketId;
  final String currentUserId;
  final String userRole;

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
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // 🔹 AppBar moderne
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 1,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.support_agent, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Support",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "En ligne",
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 🔹 Messages
  Widget _buildMessages() {
    return StreamBuilder<List<MessageModel>>(
      stream: chatController.getMessages(widget.ticketId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!;

        if (messages.isEmpty) {
          return const Center(
            child: Text(
              "Aucun message pour le moment",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // 🔔 Notification
        final lastMessage = messages.last;
        if (lastMessage.senderId != widget.currentUserId &&
            !(lastMessage.seenBy?.contains(widget.currentUserId) ?? false)) {
          NotificationService.showNotification(
            title: "Nouveau message",
            body: lastMessage.text,
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg.senderId == widget.currentUserId;

            return _buildMessageBubble(msg, isMe);
          },
        );
      },
    );
  }

  // 🔹 Bulle de message
  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight:
                isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Champ de saisie
  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Écrire un message...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Envoi message
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

    chatController.sendMessage(
      ticketId: widget.ticketId,
      message: message,
    );

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 150), () {
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
