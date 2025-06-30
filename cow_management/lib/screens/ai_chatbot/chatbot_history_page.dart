import 'package:flutter/material.dart';
import 'chatbot_quick_core.dart'; // 분리한 대화 UI

class ChatbotHistoryPage extends StatefulWidget {
  const ChatbotHistoryPage({super.key});

  @override
  State<ChatbotHistoryPage> createState() => _ChatbotHistoryPageState();
}

class _ChatbotHistoryPageState extends State<ChatbotHistoryPage> {
  bool _isSidebarOpen = true;

  final List<String> _chatSessions = [
    '오늘 오전 상담',
    '어제 저녁 기록',
    '6월 15일 대화',
  ];

  int _selectedSessionIndex = 0;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = _isSidebarOpen ? 200.0 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("소담이 채팅 기록"),
        actions: [
          // 사이드바 토글 버튼
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(_isSidebarOpen ? Icons.close_fullscreen : Icons.history_toggle_off),
              tooltip: _isSidebarOpen ? '기록 닫기' : '기록 열기',
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
          if (_isSidebarOpen) ...[
            Container(
              width: sidebarWidth,
              color: Colors.grey[100],
              child: Column(
                children: [
                  // 헤더 영역
                  Container(
                    padding: const EdgeInsets.all(12),
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      title: Text(
                                        chatName,
                                        style: TextStyle(
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
                                          "생성일: $createdAt",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      selected: _selectedChatId == chatId,
                                      onTap: () => setState(() => _selectedChatId = chatId),
                                      trailing: Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit, 
                                                size: 18,
                                                color: Colors.grey.shade600,
                                              ),
                                              tooltip: "이름 변경",
                                              onPressed: () => _renameChatRoom(chatId, chatName),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete, 
                                                size: 18,
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
                    sidebarWidth += details.delta.dx;
                    if (sidebarWidth < _minSidebarWidth) {
                      sidebarWidth = _minSidebarWidth;
                    } else if (sidebarWidth > _maxSidebarWidth) {
                      sidebarWidth = _maxSidebarWidth;
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
                          _isSidebarOpen 
                              ? "채팅방을 선택하거나 새로 시작해보세요!"
                              : "채팅방 목록을 열어서 대화를 시작해보세요!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (!_isSidebarOpen) ...[
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
                : null,
          ),
          const VerticalDivider(width: 1),
          const Expanded(
            child: ChatbotQuickCore(),
          ),
        ],
      ),
    );
  }
}
