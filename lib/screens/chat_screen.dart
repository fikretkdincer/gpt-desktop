import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:chatgptdesktop/chat_management/chat_provider.dart';
import 'package:chatgptdesktop/chat_management/chat_list.dart';
import 'package:chatgptdesktop/services/api_services.dart';
import 'package:chatgptdesktop/api_management/api_provider.dart';
import 'package:chatgptdesktop/screens/settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkApiKey();
    });
  }

  Future<void> _checkApiKey() async {
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    if (apiProvider.apiKey == null || apiProvider.apiKey!.isEmpty) {
      await _promptForApiKey();
    }
  }

  Future<void> _promptForApiKey() async {
    String? apiKey = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final TextEditingController apiController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter API Key'),
          content: TextField(
            controller: apiController,
            decoration: const InputDecoration(
              hintText: 'API Key',
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (apiController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(apiController.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (apiKey != null && apiKey.isNotEmpty) {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      await apiProvider.setApiKey(apiKey);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key Saved')),
      );
    } else {
      await _promptForApiKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var chatProvider = Provider.of<ChatProvider>(context);
    var currentChat = chatProvider.currentChat;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPT-Desktop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black38,
              child: const ChatList(),
            ),
          ),
          Expanded(
            flex: 5,
            child: currentChat == null
                ? const Center(child: Text('Start a chat'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(24.0),
                          itemCount: currentChat.messages.length,
                          itemBuilder: (context, index) {
                            final message = currentChat.messages[index];
                            final isUserMessage = message.startsWith("You:");

                            return Align(
                              alignment: isUserMessage
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(32.0),
                                    topRight: const Radius.circular(32.0),
                                    bottomLeft: isUserMessage
                                        ? const Radius.circular(32.0)
                                        : const Radius.circular(0.0),
                                    bottomRight: isUserMessage
                                        ? const Radius.circular(0.0)
                                        : const Radius.circular(32.0),
                                  ),
                                ),
                                child: Text(
                                  message,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      _buildInputField(chatProvider),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: KeyboardListener(
              focusNode: _focusNode,
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  _sendMessage(chatProvider);
                }
              },
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Send a message to ChatGPT...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  _sendMessage(chatProvider);
                },
              ),
            ),
          ),
          IconButton(
            onPressed: () => _sendMessage(chatProvider),
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }

  void _sendMessage(ChatProvider chatProvider) async {
    final String message = _controller.text.trim();

    if (message.isNotEmpty) {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final String? apiKey = apiProvider.apiKey;

      if (apiKey == null || apiKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Key is not set')),
        );
        return;
      }

      final apiService = ApiService(apiKey);
      chatProvider.updateCurrentChat('You: $message');
      _controller.clear();

      try {
        final response = await apiService.sendMessage(message);
        chatProvider.updateCurrentChat('ChatGPT: $response');
        _scrollToBottom();
      } catch (e) {
        chatProvider.updateCurrentChat('Error: Could not send message');
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
