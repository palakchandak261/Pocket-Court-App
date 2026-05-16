import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class _Message {
  final String text;
  final bool isUser;
  final DateTime time;

  _Message({required this.text, required this.isUser, DateTime? time})
      : time = time ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'time': time.toIso8601String(),
      };

  factory _Message.fromJson(Map<String, dynamic> j) => _Message(
        text: j['text'] as String,
        isUser: j['isUser'] as bool,
        time: DateTime.tryParse(j['time'] ?? '') ?? DateTime.now(),
      );
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  static const _storageKey = 'ai_chat_history';

  final List<_Message> _messages = [];
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _isTyping = false;

  // ── Quick prompts shown when chat is empty ──────────────────────────────────
  static const _quickPrompts = [
    'How do I file an FIR?',
    'What to do in UPI fraud?',
    'My landlord won\'t return deposit',
    'Rights during police arrest',
    'Workplace sexual harassment',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    if (raw.isEmpty) {
      _addWelcome();
      return;
    }
    final loaded = raw.map((e) => _Message.fromJson(jsonDecode(e))).toList();
    if (mounted) setState(() => _messages.addAll(loaded));
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    // Keep last 50 messages to avoid unbounded growth
    final toSave = _messages.length > 50
        ? _messages.sublist(_messages.length - 50)
        : _messages;
    await prefs.setStringList(
        _storageKey, toSave.map((m) => jsonEncode(m.toJson())).toList());
  }

  void _addWelcome() {
    _messages.add(_Message(
      text: "Hello! I'm your AI Legal Assistant. Ask me about your legal rights, FIR procedures, consumer complaints, traffic fines, and more.",
      isUser: false,
    ));
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('This will delete all chat history. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    if (!mounted) return;
    setState(() {
      _messages.clear();
      _addWelcome();
    });
  }

  // ── Send message ─────────────────────────────────────────────────────────────
  Future<void> _send([String? override]) async {
    final text = (override ?? _ctrl.text).trim();
    if (text.isEmpty || _isTyping) return;
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _isTyping = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    final reply = await AiService.getResponse(text);
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(_Message(text: reply, isUser: false));
    });
    _scrollToBottom();
    _saveHistory();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  // ── Copy to clipboard ────────────────────────────────────────────────────────
  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
    );
  }

  // ── Bubble widget ────────────────────────────────────────────────────────────
  Widget _bubble(_Message msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _copyMessage(msg.text),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser ? AppTheme.indigo : Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(msg.text,
                  style: TextStyle(
                      color: isUser ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                      height: 1.5)),
              const SizedBox(height: 4),
              Text(
                _formatTime(msg.time),
                style: TextStyle(
                    fontSize: 10,
                    color: isUser ? Colors.white54 : Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Typing indicator ─────────────────────────────────────────────────────────
  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _Dot(delay: i * 200)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showQuickPrompts = _messages.length <= 1 && !_isTyping;

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.smart_toy_rounded, size: 20),
          SizedBox(width: 10),
          Text('AI Legal Assistant',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear chat',
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Disclaimer banner ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: const Color(0xFFFFF8E1),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: const Text(
              '⚠️ Not official legal advice. Consult a qualified lawyer for your situation.',
              style: TextStyle(fontSize: 11, color: Color(0xFFE65100)),
            ),
          ),
          // ── Messages ────────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) return _typingIndicator();
                return _bubble(_messages[i]);
              },
            ),
          ),
          // ── Quick prompts ────────────────────────────────────────────────────
          if (showQuickPrompts)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _send(_quickPrompts[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.indigo.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.indigo.withValues(alpha: 0.2)),
                    ),
                    child: Text(_quickPrompts[i],
                        style: const TextStyle(fontSize: 12, color: AppTheme.indigo)),
                  ),
                ),
              ),
            ),
          if (showQuickPrompts) const SizedBox(height: 8),
          // ── Input bar ────────────────────────────────────────────────────────
          SafeArea(
            top: false,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      maxLines: null,
                      enabled: !_isTyping,
                      decoration: InputDecoration(
                        hintText: _isTyping ? 'AI is thinking...' : 'Describe your legal situation...',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isTyping ? null : _send,
                    child: CircleAvatar(
                      backgroundColor: _isTyping ? Colors.grey.shade300 : AppTheme.amber,
                      child: Icon(Icons.send_rounded,
                          color: _isTyping ? Colors.grey.shade500 : Colors.white,
                          size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated typing dot ───────────────────────────────────────────────────────
class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _a = Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
            color: Colors.grey.shade400, shape: BoxShape.circle),
      ),
    );
  }
}
