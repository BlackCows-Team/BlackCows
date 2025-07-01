import 'package:flutter/material.dart';
import 'package:cow_management/services/chatbot_api.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class ChatbotQuickCore extends StatefulWidget {
  const ChatbotQuickCore({super.key, this.chatId});

  final String? chatId;

  @override
  State<ChatbotQuickCore> createState() => _ChatbotQuickCoreState();
}

class _ChatbotQuickCoreState extends State<ChatbotQuickCore> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _chatId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatId;
    _loadChatHistory();
  }

  @override
  void didUpdateWidget(ChatbotQuickCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId) {
      _chatId = widget.chatId;
      _loadChatHistory();
    }
  }

  Future<void> _loadChatHistory() async {
    if (_chatId == null) {
      setState(() {
        _messages.clear();
        _messages.add(_ChatMessage(
          text: "안녕하세요 소담이입니다! 무엇을 도와드릴까요?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _messages.clear();
    });

    try {
      print('🔥 채팅 기록 불러오기 시도: chatId=$_chatId');
      final history = await getChatHistory(_chatId!);
      print('🔥 채팅 기록 응답: $history');

      if (history.isEmpty) {
        // 기존 메시지가 없으면 환영 메시지 표시
        setState(() {
          _messages.add(_ChatMessage(
            text: "안녕하세요 소담이입니다! 무엇을 도와드릴까요?",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        // 기존 메시지들을 시간순으로 정렬하여 표시
        final sortedHistory = history
            .map((msg) => _ChatMessage(
                  text: msg['content'] ?? msg['message'] ?? '',
                  isUser: msg['is_user'] == true || msg['role'] == 'user',
                  timestamp: DateTime.parse(msg['timestamp'] ?? msg['created_at'] ?? DateTime.now().toIso8601String()),
                ))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        setState(() {
          _messages.addAll(sortedHistory);
        });
      }
    } catch (e) {
      print('❌ 채팅 기록 불러오기 실패: $e');
      setState(() {
        _messages.add(_ChatMessage(
          text: "채팅 기록을 불러올 수 없습니다.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.userId;
    if (userId == null) {
      print("❌ 사용자 ID 없음");
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _controller.clear();

    _chatId ??= await createChatRoom(userId);
    if (_chatId == null) {
      _addBotMessage("채팅방 생성에 실패했어요.");
      return;
    }

    final answer = await sendChatbotMessage(
      userId: userId,
      chatId: _chatId!,
      question: text,
    );

    _addBotMessage(answer ?? "답변을 가져오지 못했어요.");
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });

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

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? '오후' : '오전';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!msg.isUser) ...[
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage('assets/images/chatbot_icon.png'),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65,
                        ),
                        child: Column(
                          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              margin: EdgeInsets.only(
                                left: msg.isUser ? 0 : 0,
                                right: msg.isUser ? 0 : 0,
                                bottom: 4,
                              ),
                              decoration: BoxDecoration(
                                color: msg.isUser ? Colors.blue.shade100 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: msg.isUser ? Colors.blue.shade200 : Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: msg.isUser ? Colors.blue.shade800 : Colors.grey.shade800,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: msg.isUser ? 0 : 4,
                                right: msg.isUser ? 4 : 0,
                                bottom: 4,
                              ),
                              child: Text(
                                _formatTime(msg.timestamp),
                                style: TextStyle(
                                  fontSize: 11, 
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (msg.isUser) ...[
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: "메시지를 입력하세요",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
