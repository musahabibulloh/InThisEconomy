import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/chat_model.dart';

class ChatRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Create a new chat session
  Future<ChatSession> createSession({String? title}) async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client.from('chat_sessions').insert({
      'user_id': userId,
      'title': title ?? 'Sesi baru',
    }).select().single();

    return ChatSession.fromJson(data);
  }

  /// Get all chat sessions for current user
  Future<List<ChatSession>> getSessions() async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('chat_sessions')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (data as List).map((e) => ChatSession.fromJson(e)).toList();
  }

  /// Get messages for a session
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final data = await _client
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return (data as List).map((e) => ChatMessage.fromJson(e)).toList();
  }

  /// Send a message and get AI response
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    // Save user message
    await _client.from('chat_messages').insert({
      'session_id': sessionId,
      'role': 'user',
      'content': content,
    });

    // Call AI chat Edge Function
    final response = await _client.functions.invoke(
      'ai-chat',
      body: {
        'session_id': sessionId,
        'message': content,
      },
    );

    if (response.status != 200) {
      throw Exception('Gagal mendapatkan respons AI: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;
    final aiContent = data['response'] as String;

    // Save AI response
    final aiMessage = await _client.from('chat_messages').insert({
      'session_id': sessionId,
      'role': 'assistant',
      'content': aiContent,
    }).select().single();

    // Update session timestamp
    await _client.from('chat_sessions').update({
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', sessionId);

    return ChatMessage.fromJson(aiMessage);
  }

  /// Delete a chat session
  Future<void> deleteSession(String id) async {
    await _client.from('chat_sessions').delete().eq('id', id);
  }
}
