import 'package:flutter/material.dart';
import '../controllers/chat_controller.dart';
import '../models/message.dart';

class ChatView extends StatefulWidget {
  final String ticketId;
  final String currentUserId;
  final String userType;

  const ChatView({
    super.key,
    required this.ticketId,
    required this.currentUserId,
    required this.userType,
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
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        title: const Text("Discussion"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ✅ Messages
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatController.getMessages(widget.ticketId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment:
                            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.person,
                                  size: 16, color: Colors.white),
                            ),

                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            margin: const EdgeInsets.only(bottom: 10),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    color:
                                        isMe ? Colors.white : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (isMe) const SizedBox(width: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ Zone d’envoi
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4),
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
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final message = MessageModel(
      id: '',
      senderId: widget.currentUserId,
      senderRole: widget.userType,
      text: _controller.text.trim(),
      createdAt: DateTime.now(),
      seenBy: [widget.currentUserId],
    );

    chatController.sendMessage(
      ticketId: widget.ticketId,
      message: message,
    );

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
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
