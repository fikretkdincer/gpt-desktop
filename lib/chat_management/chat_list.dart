import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_provider.dart';
import 'chat.dart';
import 'package:uuid/uuid.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    var chatManager = Provider.of<ChatProvider>(context);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: chatManager.chats.length,
            itemBuilder: (context, index) {
              var chat = chatManager.chats[index];
              return Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[900],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(chat.title),
                        onTap: () {
                          chatManager.selectChat(chat.id);
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        chatManager.deleteChat(chat.id);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _createNewChat(context);
          },
          child: const Text('Create Chat'),
        ),
        const SizedBox(
          height: 5.0,
        ),
      ],
    );
  }

  void _createNewChat(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _showNewChatDialog(context, chatProvider);
  }

  Future<void> _showNewChatDialog(
      BuildContext context, ChatProvider chatProvider) async {
    final TextEditingController chatNameController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Chat'),
          content: TextField(
            controller: chatNameController,
            decoration: const InputDecoration(hintText: 'Enter chat name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                final chatName = chatNameController.text.trim();
                if (chatName.isNotEmpty) {
                  chatProvider.addChat(Chat(
                    title: chatName,
                    id: const Uuid().v4(),
                    messages: [],
                  ));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat name cannot be empty')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
