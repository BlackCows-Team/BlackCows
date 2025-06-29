// chatbot_history_page.dart
import 'package:flutter/material.dart';
import 'package:cow_management/services/chatbot_api.dart';
import 'package:cow_management/screens/ai_chatbot/chatbot_quick_core.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class ChatbotHistoryPage extends StatefulWidget {
  const ChatbotHistoryPage({super.key});

  @override
  State<ChatbotHistoryPage> createState() => _ChatbotHistoryPageState();
}

class _ChatbotHistoryPageState extends State<ChatbotHistoryPage> {
  List<Map<String, dynamic>> _chatRooms = [];
  bool _isLoading = true;
  String? _selectedChatId;

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  Future<void> _fetchChatRooms() async {
    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.userId;
    print("🔥 userId: $userId");
    if (userId == null) return;

    final rooms = await getChatRoomList(userId);
    setState(() {
      _chatRooms = rooms;
      _isLoading = false;
    });
  }

  Future<void> _createNewChatRoom() async {
    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.userId;
    if (userId == null) return;

    final newChatId = await createChatRoom(userId);
    if (newChatId != null) {
      await _fetchChatRooms();
      setState(() {
        _selectedChatId = newChatId;
      });
    }
  }

  Future<void> _deleteChatRoom(String chatId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("삭제 확인"),
        content: const Text("이 채팅방을 삭제할까요?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제")),
        ],
      ),
    );

    if (confirm == true) {
      await deleteChatRoom(chatId);
      await _fetchChatRooms();
      if (_selectedChatId == chatId) {
        setState(() => _selectedChatId = null);
      }
    }
  }

  String _formatDate(String iso) {
    final date = DateTime.parse(iso);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("소담이 채팅 기록"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: "새 채팅 시작",
            onPressed: _createNewChatRoom,
          ),
        ],
      ),
      body: Row(
        children: [
          // 🟦 왼쪽 채팅방 목록
          Container(
            width: 220,
            color: Colors.grey[100],
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('채팅 기록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _chatRooms.isEmpty
                          ? const Center(child: Text("채팅방이 없습니다"))
                          : ListView.builder(
                              itemCount: _chatRooms.length,
                              itemBuilder: (context, index) {
                                final chat = _chatRooms[index];
                                final chatId = chat['chat_id'];
                                final createdAt = _formatDate(chat['created_at']);
                                return ListTile(
                                  title: Text("채팅 ${_chatRooms.length - index}"),
                                  subtitle: Text("생성일: $createdAt"),
                                  selected: _selectedChatId == chatId,
                                  onTap: () => setState(() => _selectedChatId = chatId),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteChatRoom(chatId),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),

          // 🟨 오른쪽 챗봇 대화 영역
          Expanded(
            child: _selectedChatId == null
                ? const Center(child: Text("채팅방을 선택하거나 새로 시작해보세요!"))
                : ChatbotQuickCore(
                    key: ValueKey(_selectedChatId),
                    chatId: _selectedChatId!,
                  ),
          ),
        ],
      ),
    );
  }
}
