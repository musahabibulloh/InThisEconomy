import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/chat_repository.dart';
import '../domain/chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _repo = ChatRepository();
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  ChatSession? _session;
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() { super.initState(); _initSession(); }

  @override
  void dispose() { _msgController.dispose(); _scrollController.dispose(); super.dispose(); }

  Future<void> _initSession() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await _repo.getSessions();
      if (sessions.isNotEmpty) {
        _session = sessions.first;
        _messages = await _repo.getMessages(_session!.id);
      } else {
        _session = await _repo.createSession(title: 'Konsultasi Bisnis');
      }
    } catch (e) {
      // Handle error silently for now
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _session == null) return;

    _msgController.clear();
    setState(() {
      _isSending = true;
      _messages.add(ChatMessage(id: 'temp-${DateTime.now().millisecondsSinceEpoch}', sessionId: _session!.id, role: 'user', content: text, createdAt: DateTime.now()));
    });
    _scrollToBottom();

    try {
      final aiMsg = await _repo.sendMessage(sessionId: _session!.id, content: text);
      if (mounted) setState(() { _messages.add(aiMsg); _isSending = false; });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accent));
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
        title: const Text('Konsultasi AI'),
        actions: [
          IconButton(icon: const Icon(Icons.add_comment_outlined), onPressed: () async {
            _session = await _repo.createSession(title: 'Sesi ${DateTime.now().hour}:${DateTime.now().minute}');
            setState(() => _messages = []);
          }, tooltip: 'Sesi baru'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              // Info banner
              if (_messages.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlassCard(
                    gradient: LinearGradient(colors: [AppColors.secondary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.03)]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Text('AI Konsultan Bisnis', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondary)),
                      ]),
                      const SizedBox(height: 10),
                      Text('Tanyakan apa saja tentang ide bisnismu. AI ini memiliki konteks dari riwayat analisis idemu, sehingga bisa menjawab secara spesifik.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        _suggestionChip('Kenapa persaingan saya tinggi?'),
                        _suggestionChip('Bagaimana strategi diferensiasi?'),
                        _suggestionChip('Berapa modal awal yang dibutuhkan?'),
                      ]),
                    ]),
                  ).animate().fadeIn(duration: 400.ms),
                ),
              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _messages.length + (_isSending ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _messages.length && _isSending) return _buildTypingIndicator();
                    return _buildMessageBubble(_messages[i]);
                  },
                ),
              ),
              // Input bar
              Container(
                padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
                decoration: BoxDecoration(color: AppColors.bgDarkSecondary, border: Border(top: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.1)))),
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _msgController,
                    maxLines: 4, minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Tanya sesuatu...', filled: true, fillColor: AppColors.surfaceDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                    onSubmitted: (_) => _sendMessage(),
                  )),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                    child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: _isSending ? null : _sendMessage),
                  ),
                ]),
              ),
            ]),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          gradient: isUser ? AppColors.primaryGradient : null,
          color: isUser ? null : AppColors.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4), bottomRight: Radius.circular(isUser ? 4 : 18)),
          border: isUser ? null : Border.all(color: AppColors.textMuted.withValues(alpha: 0.15))),
        child: Text(msg.content, style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 14, height: 1.5)),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTypingIndicator() {
    return Align(alignment: Alignment.centerLeft, child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.15))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ...List.generate(3, (i) => Container(width: 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle))
          .animate(onPlay: (c) => c.repeat()).fadeIn(delay: Duration(milliseconds: i * 200)).fadeOut(delay: 600.ms)),
      ]),
    ));
  }

  Widget _suggestionChip(String text) {
    return GestureDetector(
      onTap: () { _msgController.text = text; _sendMessage(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
        child: Text(text, style: TextStyle(color: AppColors.primaryLight, fontSize: 12)),
      ),
    );
  }
}
