import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/chat_message.dart';
import '../../../shared/widgets/demo_badge.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isDemo = false;

  String _userName = "Friend";
  final List<ChatMessage> _messages = [
    ChatMessage(
      role: "assistant",
      content:
          "Hello Friend! 🌿 I'm BreathIQ, your personal environmental companion. How can I help you breathe easier and live greener today?",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initChatGreeting();
  }

  Future<void> _initChatGreeting() async {
    try {
      final prof = await apiClient.getUserProfile();
      if (prof['display_name'] != null && (prof['display_name'] as String).isNotEmpty) {
        _userName = prof['display_name'];
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        if (_messages.isNotEmpty && _messages.first.role == "assistant") {
          _messages[0] = ChatMessage(
            role: "assistant",
            content:
                "Hello $_userName! 🌿 I'm BreathIQ, your personal environmental companion. How can I help you breathe easier and live greener today?",
          );
        }
      });
    }
  }

  final List<String> _quickActionChips = [
    "🏃‍♂️ Is it safe to run?",
    "🚇 Compare my commute",
    "🪟 Indoor air tips",
    "📊 Explain my AQI",
  ];

  void _sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(role: "user", content: clean));
      _isTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final apiMsgs = _messages.map((m) => m.toApiMap()).toList();
      final res = await apiClient.chatWithAssistant(
        apiMsgs,
        contextOverride: {"user_name": _userName},
      );

      final reply = res['response'] ?? "I'm right here with your environmental data!";
      final demoModeActive = res['is_demo'] ?? false;

      setState(() {
        _isDemo = demoModeActive;
        _messages.add(ChatMessage(role: "assistant", content: reply));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      final q = text.toLowerCase();
      String fallbackReply = "";
      if (q.contains("jog") || q.contains("run") || q.contains("walk") || q.contains("workout")) {
        fallbackReply = "Given current urban particulate levels, indoor cardio or stretching will protect your respiratory health while keeping you energized! 🏃‍♂️🏠";
      } else if (q.contains("metro") || q.contains("car") || q.contains("commute") || q.contains("travel")) {
        fallbackReply = "Switching your commute to the metro or an electric bus cuts your travel footprint by ~80% compared to driving a petrol car! 🚇🌱";
      } else if (q.contains("window") || q.contains("cook") || q.contains("indoor") || q.contains("air")) {
        fallbackReply = "Remember to keep kitchen exhaust on while cooking, and close windows during morning rush hour (8–10 AM) to maintain pristine indoor air! 🪟✨";
      } else {
        fallbackReply = "Hello $_userName! I'm monitoring your air quality and lifestyle impact in real-time. Feel free to ask about safe outdoor exercise, clean travel routes, or green living tips! 🌿";
      }
      setState(() {
        _isDemo = true;
        _messages.add(ChatMessage(role: "assistant", content: fallbackReply));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BreathIQ Assistant"),
        actions: [
          if (_isDemo)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: DemoBadge(label: "🔶 Demo AI")),
            ),
        ],
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == "user";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primarySage : AppColors.cardWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                      border: Border.all(color: AppColors.borderSoft),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.content,
                      style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary),
                    ),
                  ),
                );
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("BreathIQ is thinking... 🌿", style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
              ),
            ),

          // Quick Action Chips
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickActionChips.length,
              itemBuilder: (context, idx) {
                final chip = _quickActionChips[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(chip, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.cardWhite,
                    side: const BorderSide(color: AppColors.borderSoft),
                    onPressed: () => _sendMessage(chip),
                  ),
                );
              },
            ),
          ),

          // Chat Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.cardWhite,
              border: Border(top: BorderSide(color: AppColors.borderSoft)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Ask about air quality, workout safety...",
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.borderSoft),
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primarySage,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, color: AppColors.textPrimary),
                      onPressed: () => _sendMessage(_textController.text),
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
