import 'package:flutter/material.dart';
import '../utils/app_config.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String sentiment;

  const ChatBubble({super.key, required this.text, required this.isUser, required this.sentiment});

  Color _getSentimentColor() {
    if (sentiment == 'TICH_CUC') return AppConfig.positiveColor;
    if (sentiment == 'TIEU_CUC') return AppConfig.negativeColor;
    return AppConfig.neutralColor;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? AppConfig.lightNavy : AppConfig.darkNavy,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24), topRight: const Radius.circular(24),
            bottomLeft: isUser ? const Radius.circular(24) : const Radius.circular(8),
            bottomRight: isUser ? const Radius.circular(8) : const Radius.circular(24),
          ),
          border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: isUser ? AppConfig.primaryColor : Colors.white, fontSize: 16, height: 1.4)),
            if (!isUser && sentiment != 'TRUNG_LAP') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _getSentimentColor().withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: _getSentimentColor().withValues(alpha: 0.5))),
                child: Text(sentiment, style: TextStyle(color: _getSentimentColor(), fontSize: 11, fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
      ),
    );
  }
}