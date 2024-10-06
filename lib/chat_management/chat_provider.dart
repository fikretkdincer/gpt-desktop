import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'chat.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final List<Chat> _chats = [];
  Chat? _currentChat;
  late Box<Chat> _chatBox;

  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;

  ChatProvider() {
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    _chatBox = Hive.box<Chat>('chats');

    _chats.addAll(_chatBox.values);

    if (_chats.isEmpty) {
      addChat(Chat(
        title: 'New Chat',
        id: const Uuid().v4(),
        messages: [],
      ));
    } else {
      _currentChat = _chats.first;
    }
    notifyListeners();
  }

  Future<void> addChat(Chat chat) async {
    _chats.add(chat);
    _currentChat = chat;

    await _chatBox.put(chat.id, chat);
    notifyListeners();
  }

  Future<void> deleteChat(String id) async {
    _chats.removeWhere((conv) => conv.id == id);

    await _chatBox.delete(id);

    if (_currentChat?.id == id) {
      _currentChat = _chats.isNotEmpty ? _chats.first : null;
    }
    notifyListeners();
  }

  void selectChat(String id) {
    _currentChat = _chats.firstWhere((conv) => conv.id == id);
    notifyListeners();
  }

  Future<void> updateCurrentChat(String message) async {
    if (_currentChat != null) {
      _currentChat!.messages.add(message);
      await _currentChat!.save();
      notifyListeners();
    }
  }
}
