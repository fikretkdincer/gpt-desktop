import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatgptdesktop/chat_management/chat_provider.dart';
import 'package:chatgptdesktop/screens/chat_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chatgptdesktop/chat_management/chat.dart';
import 'package:chatgptdesktop/api_management/api_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ChatAdapter());

  await Hive.openBox<Chat>('chats');
  await Hive.openBox<String>('settings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => ApiProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: const ChatScreen(),
      ),
    );
  }
}
