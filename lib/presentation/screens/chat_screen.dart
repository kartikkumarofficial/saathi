import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String walkRequestId;
  final String walkerId;
  final String wandererId;
  final Map<String, dynamic> requestData;

  const ChatScreen({
    Key? key,
    required this.walkRequestId,
    required this.walkerId,
    required this.wandererId,
    required this.requestData,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final supabase = Supabase.instance.client;
  final messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
    listenForNewMessages();
  }

  Future<void> fetchMessages() async {
    final res = await supabase
        .from('messages')
        .select()
        .eq('walk_request_id', widget.walkRequestId)
        .order('created_at', ascending: true);

    setState(() {
      messages = List<Map<String, dynamic>>.from(res);
    });
  }

  void listenForNewMessages() {
    supabase.channel('public:messages').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        if (payload.newRecord['walk_request_id'] == widget.walkRequestId) {
          setState(() {
            messages.add(payload.newRecord);
          });
        }
      },
    ).subscribe();
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    final text = messageController.text.trim();

    await supabase.from('messages').insert({
      'walk_request_id': widget.walkRequestId,
      'sender_id': widget.walkerId,
      'content': text,
      'created_at': DateTime.now().toIso8601String(),
    });

    setState(() {
      messages.add({
        'sender_id': widget.walkerId,
        'content': text,
      });
      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wandererName = widget.requestData['wanderer_name'] ?? 'Wanderer';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8B57),
        title: Text(
          "Chat with $wandererName",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMine = msg['sender_id'] == widget.walkerId;

                return Align(
                  alignment:
                  isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMine
                          ? const Color(0xFF2E8B57).withOpacity(0.9)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isMine
                            ? const Radius.circular(12)
                            : const Radius.circular(0),
                        bottomRight: isMine
                            ? const Radius.circular(0)
                            : const Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(
                        color: isMine ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF2E8B57)),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
