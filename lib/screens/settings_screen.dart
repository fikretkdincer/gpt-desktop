import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatgptdesktop/api_management/api_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);
    final TextEditingController apiController =
        TextEditingController(text: apiProvider.apiKey ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: apiController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String newKey = apiController.text.trim();
                if (newKey.isNotEmpty) {
                  await apiProvider.setApiKey(newKey);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API Key Updated')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
