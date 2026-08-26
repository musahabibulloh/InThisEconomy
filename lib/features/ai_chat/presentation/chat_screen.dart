import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/ite_avatar.dart';
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
  void initState() {
    super.initState();
    _initSession();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
      _messages.add(ChatMessage(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: _session!.id,
        role: 'user',
        content: text,
        createdAt: DateTime.now(),
      ));
    });
    _scrollToBottom();

    try {
      final aiMsg =
          await _repo.sendMessage(sessionId: _session!.id, content: text);
      if (mounted) {
        setState(() {
          _messages.add(aiMsg);
          _isSending = false;
        });
      }
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapat respons: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showHistory() async {
    final sessions = await _repo.getSessions();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Riwayat Obrolan',
                style: AppTheme.displayFont(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: sessions.isEmpty
                    ? const Center(child: Text('Belum ada riwayat chat.'))
                    : ListView.builder(
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          return ListTile(
                            leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                            title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              'Diperbarui: ${session.updatedAt.toLocal().toString().split('.')[0]}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              setState(() => _isLoading = true);
                              _session = session;
                              _messages = await _repo.getMessages(session.id);
                              if (mounted) setState(() => _isLoading = false);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop()),
        title: const Text('Konsultasi AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: _showHistory,
            tooltip: 'Riwayat Chat',
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () async {
              _session = await _repo.createSession(
                  title:
                      'Sesi ${DateTime.now().hour}:${DateTime.now().minute}');
              setState(() => _messages = []);
            },
            tooltip: 'Mulai sesi baru',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Messages ──
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: _messages.isEmpty
                        ? (_isSending ? 2 : 1)
                        : _messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (_messages.isEmpty) {
                        if (i == 0) return _buildEmptyState();
                        if (i == 1 && _isSending) return _buildTypingIndicator();
                        return const SizedBox.shrink();
                      }

                      if (i == _messages.length && _isSending) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[i]);
                    },
                  ),
                ),

                // ── Input bar ──
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 8,
                    top: 8,
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite(0.9),
                    border: Border(
                      top: BorderSide(
                          color: AppColors.glassBorder()),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          maxLines: 4,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Curhat bisnis sama Ite... 🐻',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                          onPressed: _isSending ? null : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.role == 'user';
    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.70), // Reduced max width to fit avatar
      decoration: BoxDecoration(
        gradient: isUser ? AppColors.primaryGradient : null,
        color: isUser ? null : AppColors.glassWhite(0.85),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        border: isUser
            ? null
            : Border.all(color: AppColors.glassBorder(0.6)),
      ),
      child: Text(
        msg.content,
        style: TextStyle(
          color: isUser ? Colors.white : AppColors.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: bubble,
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              width: 32,
              height: 32,
              child: SvgPicture.asset('assets/icons/ite_chat.svg'),
            ),
            Flexible(child: bubble),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
    }
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 4),
            width: 32,
            height: 32,
            child: SvgPicture.asset('assets/icons/ite_chat.svg'),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.glassWhite(0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder(0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(
                  3,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(delay: Duration(milliseconds: i * 200))
                      .fadeOut(delay: 600.ms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/icons/ite_chat.svg', width: 28, height: 28),
                const SizedBox(width: 8),
                Text(
                  'Ite si Konsultan Bisnis',
                  style: AppTheme.displayFont(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Halo Kak! Aku Ite 🐻, teman bisnismu yang paling suka data! Aku udah baca-baca riwayat cek ide bisnismu, lho.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ada yang bikin bingung soal modal, cara promosi, atau peluang pasar? Sini cerita aja, Ite bantuin carikan celahnya! 💪',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _suggestionChip('📣 Gimana strategi promosi yang pas?'),
                _suggestionChip('🎯 Bantu bedain usahaku dari pesaing dong!'),
                _suggestionChip('💰 Berapa ya modal awal buat ideku?'),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _suggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _msgController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          text,
          style: TextStyle(color: AppColors.primaryLight, fontSize: 12),
        ),
      ),
    );
  }
}
