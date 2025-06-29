import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/services/dio_client.dart';

// DioClient 사용하도록 변경
final Dio _dio = DioClient().dio;

// 채팅방 생성
Future<String?> createChatRoom(String userId) async {
  try {
    print('🔥 채팅방 생성 시도: userId=$userId');
    final response = await _dio.post('/chatbot/rooms', data: {
      'user_id': userId,
    });
    print('🔥 채팅방 생성 응답: ${response.data}');
    return response.data['chats'][0]['chat_id'];
  } catch (e) {
    print('❌ 채팅방 생성 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return null;
  }
}

// 질문 전송
Future<String?> sendChatbotMessage({
  required String userId,
  required String chatId,
  required String question,
}) async {
  try {
    final response = await _dio.post('/chatbot/ask', data: {
      'user_id': userId,
      'chat_id': chatId,
      'question': question,
    });
    return response.data['answer'];
  } catch (e) {
    print('❌ 챗봇 질문 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return "답변을 불러올 수 없습니다.";
  }
}

// 채팅방 목록 조회
Future<List<Map<String, dynamic>>> getChatRoomList(String userId) async {
  try {
    print('🔥 채팅방 목록 조회 시도: userId=$userId');
    final response = await _dio.get('/chatbot/rooms/$userId');
    print('🔥 채팅방 목록 응답: ${response.data}');
    
    if (response.data['chats'] == null) {
      print('❌ chats 필드가 없음: ${response.data}');
      return [];
    }
    
    final List chats = response.data['chats'];
    return chats.cast<Map<String, dynamic>>();
  } catch (e) {
    print('❌ 채팅방 목록 불러오기 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
      print('❌ 상태 코드: ${e.response?.statusCode}');
    }
    return [];
  }
}

// 채팅 기록 불러오기
Future<List<Map<String, dynamic>>> getChatHistory(String chatId) async {
  try {
    print('🔥 채팅 기록 불러오기 시도: chatId=$chatId');
    final response = await _dio.get('/chatbot/history/$chatId');
    print('🔥 채팅 기록 응답: ${response.data}');
    
    if (response.data['messages'] == null) {
      print('❌ messages 필드가 없음: ${response.data}');
      return [];
    }
    
    final List messages = response.data['messages'];
    return messages.cast<Map<String, dynamic>>();
  } catch (e) {
    print('❌ 채팅 기록 불러오기 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return [];
  }
}

// 채팅방 삭제
Future<bool> deleteChatRoom(String chatId) async {
  try {
    await _dio.delete('/chatbot/rooms/$chatId');
    return true;
  } catch (e) {
    print('❌ 채팅방 삭제 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return false;
  }
}