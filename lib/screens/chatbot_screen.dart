import 'package:flutter/material.dart';
import '../utils/glass_morphism.dart';
import '../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  final String? initialQuery;

  const ChatbotScreen({super.key, this.initialQuery});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService _chatbotService = ChatbotService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [
    {
      "isUser": false,
      "text": "Hello! I’m your B-RMMS AI medical assistant specializing in melanoma. I can provide general screening information, but please consult a dermatologist for official medical advice."
    }
  ];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      // Defer the sending slightly so the UI finishes building first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialQuery!);
      });
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"isUser": true, "text": text});
      _isTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    final response = await _chatbotService.sendMessage(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({"isUser": false, "text": response});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.grey[900];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _QuickButton('What causes melanoma?', (text) => _sendMessage(text)),
                            _QuickButton('What are the ABCDE signs?', (text) => _sendMessage(text)),
                            _QuickButton('How does the Gaussian Blur help?', (text) => _sendMessage(text)),
                            _QuickButton('How to prevent it?', (text) => _sendMessage(text)),
                          ],
                        ),
                      );
                    }
                    
                    final msg = _messages[index - 1];
                    return _ChatBubble(
                      isUser: msg['isUser'],
                      message: msg['text'],
                      context: context
                    );
                  },
                ),
              ),
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(width: 8),
                      Text("AI is typing...", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12))
                    ]
                  ),
                ),
              GlassContainer(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(color: primaryColor),
                        decoration: InputDecoration(
                          hintText: 'Type your medical question...',
                          hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () => _sendMessage(_textController.text),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 4, left: 24, right: 24),
                child: Text(
                  'For emergencies, please contact your healthcare provider immediately.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final BuildContext context;

  const _ChatBubble({required this.isUser, required this.message, required this.context});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GlassContainer(
        width: MediaQuery.of(context).size.width * 0.75,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String text;
  final Function(String) onTap;

  const _QuickButton(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onTap(text),
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
        child: Text(
          text, 
          style: TextStyle(color: isDark ? Colors.white : Theme.of(context).colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w500)
        ),
      ),
    );
  }
}