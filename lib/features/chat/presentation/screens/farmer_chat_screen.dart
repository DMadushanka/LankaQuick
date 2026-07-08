import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/marketplace/presentation/providers/farmer_marketplace_provider.dart';

class LocalMessage {
  final String id;
  final String sender; // "user" or "farmer"
  final String text;
  final String time;

  LocalMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
  });
}

class FarmerChatScreen extends ConsumerStatefulWidget {
  final FarmerPost post;

  const FarmerChatScreen({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<FarmerChatScreen> createState() => _FarmerChatScreenState();
}

class _FarmerChatScreenState extends ConsumerState<FarmerChatScreen> {
  final List<LocalMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _quickReplies = [
    "Is this organic?",
    "What's the minimum order?",
    "Can you deliver today?",
    "Do you offer bulk discount?",
  ];

  @override
  void initState() {
    super.initState();
    // Pre-populate with initial Figma design messages
    final nowTime = _getFormattedTime();
    _messages.addAll([
      LocalMessage(
        id: "m1",
        sender: "farmer",
        text: "ආයුබෝවන්! 🙏 Hello! I'm glad you're interested in my produce. How can I help you today?",
        time: nowTime,
      ),
      LocalMessage(
        id: "m2",
        sender: "user",
        text: "Hi! Are your tomatoes available for delivery to Gampaha this week?",
        time: nowTime,
      ),
      LocalMessage(
        id: "m3",
        sender: "farmer",
        text: "Yes! I deliver to Gampaha every Tuesday and Friday. Minimum 5 kg for delivery. Would you like to place an order?",
        time: nowTime,
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final ampm = now.hour >= 12 ? "PM" : "AM";
    return "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $ampm";
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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = LocalMessage(
      id: "u_${DateTime.now().millisecondsSinceEpoch}",
      sender: "user",
      text: text.trim(),
      time: _getFormattedTime(),
    );

    setState(() {
      _messages.add(userMsg);
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // Mapping replies exactly from FarmerChatScreen.tsx
    final Map<String, String> farmerResponses = {
      "Is this organic?": "Yes! Our ${widget.post.title} are grown without any chemical pesticides or synthetic fertilizers. We follow traditional farming methods. 🌿",
      "What's the minimum order?": "The minimum order for ${widget.post.title} is ${widget.post.minOrder.toStringAsFixed(0)} ${widget.post.unit}. For orders above 10 ${widget.post.unit}, I can offer a small discount!",
      "Can you deliver today?": "I can arrange same-day delivery for orders placed before 11 AM. For today, it might be by evening. Let me check my schedule!",
      "Do you offer bulk discount?": "Absolutely! For orders above 20 kg, I offer a 10% discount. Above 50 kg, we can negotiate a better price. Contact me directly! 😊",
    };

    final defaultResponse = "Thank you for your message! I'll get back to you shortly about the ${widget.post.title}. You can also call me directly for faster response. 🌾";

    final responseText = farmerResponses[text.trim()] ?? defaultResponse;

    final delay = 1200 + Random().nextInt(600);
    Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      final farmerMsg = LocalMessage(
        id: "f_${DateTime.now().millisecondsSinceEpoch}",
        sender: "farmer",
        text: responseText,
        time: _getFormattedTime(),
      );
      setState(() {
        _messages.add(farmerMsg);
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final post = widget.post;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // Chat Custom Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Farmer Avatar
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFFF97316).withOpacity(0.12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          post.farmerAvatar,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppTheme.darkCard : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Farmer Info Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.farmerName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            if (post.farmerVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Color(0xFF22C55E), size: 14),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Online · Farmer",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active context product pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkInput : AppTheme.lightInput,
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            post.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Re:",
                              style: TextStyle(
                                fontSize: 8,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              ),
                            ),
                            Text(
                              post.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Message Bubble list view
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg.sender == "user";

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isMe 
                            ? AppTheme.primaryColor 
                            : (isDark ? AppTheme.darkCard : Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMe ? 18 : 2),
                          bottomRight: Radius.circular(isMe ? 2 : 18),
                        ),
                        border: isMe ? null : Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        ),
                        boxShadow: !isMe && !isDark
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : (isDark ? const Color(0xFFE0E0E0) : AppTheme.lightTextPrimary),
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              msg.time,
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe 
                                    ? Colors.white.withOpacity(0.7) 
                                    : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Typing Indicator
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        "${post.farmerName} is typing",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Quick replies chips
            Container(
              height: 38,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickReplies.length,
                itemBuilder: (context, index) {
                  final reply = _quickReplies[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(
                        reply,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                      side: BorderSide(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
                      ),
                      onPressed: () => _sendMessage(reply),
                    ),
                  );
                },
              ),
            ),

            // Text messaging bottom input bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBg : AppTheme.lightBg,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) => _sendMessage(val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _sendMessage(_controller.text);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33F97316),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
