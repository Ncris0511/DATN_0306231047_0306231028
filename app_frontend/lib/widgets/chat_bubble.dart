import 'package:flutter/material.dart';
import '../utils/app_config.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String sentiment; // TICH_CUC, TIEU_CUC, TRUNG_LAP

  const ChatBubble({
    super.key, 
    required this.text, 
    required this.isUser, 
    required this.sentiment
  });

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
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppConfig.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), // Sửa lỗi withOpacity
              blurRadius: 5, 
              offset: const Offset(0, 2)
            )
          ],
          border: isUser ? null : Border.all(color: _getSentimentColor()),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            if (!isUser) ...[
              const SizedBox(height: 4),
              Text(
                "Sentiment: $sentiment",
                style: TextStyle(color: _getSentimentColor(), fontSize: 10, fontWeight: FontWeight.bold),
              )
            ]
          ],
        ),
      ),
    );
  }
}