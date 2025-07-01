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
  
  // 사이드바 상태 관리
  bool _isSidebarVisible = true;
  double _sidebarWidth = 280.0;
  double _minSidebarWidth = 200.0;
  double _maxSidebarWidth = 400.0;
  bool _isResizing = false;

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

  Future<void> _renameChatRoom(String chatId, String currentName) async {
    final TextEditingController nameController = TextEditingController(text: currentName);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit, color: Colors.blue.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            const Text("채팅방 이름 변경"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "새로운 채팅방 이름을 입력하세요:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: '채팅방 이름',
                hintText: '예: 젖소 질문, 건강 검진 문의',
                prefixIcon: const Icon(Icons.chat_bubble_outline),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              autofocus: true,
              maxLength: 30,
              onSubmitted: (value) {
                final newName = value.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context, newName);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              "현재 이름: $currentName",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context, newName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('채팅방 이름을 입력해주세요.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("변경"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final success = await updateChatRoomName(chatId, result);
      
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('채팅방 이름이 변경되었습니다.'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        await _fetchChatRooms();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Text('채팅방 이름 변경에 실패했습니다.'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  String _formatDate(String iso) {
    final date = DateTime.parse(iso);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _getChatRoomName(Map<String, dynamic> chat) {
    // name 필드가 있으면 사용, 없으면 기본 이름 생성
    final name = chat['name'];
    if (name != null && name.isNotEmpty) {
      return name;
    }
    
    // 기본 이름: "채팅 N" 형태
    final index = _chatRooms.indexOf(chat);
    return "채팅 ${_chatRooms.length - index}";
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("소담이 채팅 기록"),
        actions: [
          // 사이드바 토글 버튼
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
              tooltip: _isSidebarVisible ? "채팅방 목록 숨기기" : "채팅방 목록 보이기",
              onPressed: _toggleSidebar,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              tooltip: "새 채팅 시작",
              onPressed: _createNewChatRoom,
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // 🟦 왼쪽 채팅방 목록 (조건부 렌더링)
          if (_isSidebarVisible) ...[
            Container(
              width: _sidebarWidth,
              color: Colors.grey[50],
              child: Column(
                children: [
                  // 헤더 영역
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '채팅 기록',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        // 사이드바 크기 조절 버튼
                        IconButton(
                          icon: const Icon(Icons.drag_handle, size: 20),
                          tooltip: "크기 조절",
                          onPressed: () {
                            // 크기 조절 모드 토글
                            setState(() {
                              _isResizing = !_isResizing;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // 채팅방 목록
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _chatRooms.isEmpty
                            ? const Center(child: Text("채팅방이 없습니다"))
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: _chatRooms.length,
                                itemBuilder: (context, index) {
                                  final chat = _chatRooms[index];
                                  final chatId = chat['chat_id'];
                                  final createdAt = _formatDate(chat['created_at']);
                                  final chatName = _getChatRoomName(chat);
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedChatId == chatId 
                                            ? Colors.blue.shade300 
                                            : Colors.grey.shade200,
                                        width: _selectedChatId == chatId ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                      title: Text(
                                        chatName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedChatId == chatId 
                                              ? Colors.blue.shade700 
                                              : Colors.grey.shade800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          createdAt,
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      selected: _selectedChatId == chatId,
                                      onTap: () => setState(() => _selectedChatId = chatId),
                                      trailing: Container(
                                        margin: const EdgeInsets.only(left: 2),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit, 
                                                size: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                              tooltip: "이름 변경",
                                              onPressed: () => _renameChatRoom(chatId, chatName),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete, 
                                                size: 14,
                                                color: Colors.red.shade400,
                                              ),
                                              tooltip: "삭제",
                                              onPressed: () => _deleteChatRoom(chatId),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
            // 크기 조절 핸들
            if (_isResizing)
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _sidebarWidth += details.delta.dx;
                    if (_sidebarWidth < _minSidebarWidth) {
                      _sidebarWidth = _minSidebarWidth;
                    } else if (_sidebarWidth > _maxSidebarWidth) {
                      _sidebarWidth = _maxSidebarWidth;
                    }
                  });
                },
                child: Container(
                  width: 4,
                  color: Colors.grey.shade400,
                  child: const Center(
                    child: Icon(
                      Icons.drag_handle,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
              ),
            const VerticalDivider(width: 1),
          ],

          // 🟨 오른쪽 챗봇 대화 영역
          Expanded(
            child: _selectedChatId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isSidebarVisible 
                              ? "채팅방을 선택하거나 새로 시작해보세요!"
                              : "채팅방 목록을 열어서 대화를 시작해보세요!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (!_isSidebarVisible) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _toggleSidebar,
                            icon: const Icon(Icons.menu),
                            label: const Text("채팅방 목록 열기"),
                          ),
                        ],
                      ],
                    ),
                  )
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
