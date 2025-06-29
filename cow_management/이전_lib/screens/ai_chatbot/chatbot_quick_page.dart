// chatbot_quick_page.dart

import 'package:flutter/material.dart';
import 'chatbot_quick_core.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소담소담 상담 챗봇'),
        backgroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: true,
      body: const SafeArea(
        child: ChatbotQuickCore(),
      ),
    );
  }
}
