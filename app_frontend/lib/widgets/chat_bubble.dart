import 'package:flutter/material.dart';
import '../utils/app_config.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String sentiment;
  final dynamic ketQuaAI; // Truyền toàn bộ object AI vào đây

  const ChatBubble({super.key, required this.text, required this.isUser, required this.sentiment, this.ketQuaAI});

  Color _getSentimentColor() {
    if (sentiment == 'TICH_CUC') return AppConfig.positiveColor;
    if (sentiment == 'TIEU_CUC') return AppConfig.negativeColor;
    return AppConfig.neutralColor;
  }

  // Dialog Giải thích độ tin cậy của AI
  void _showExplainDialog(BuildContext context) {
    if (isUser || ketQuaAI == null) return;
    showModalBottomSheet(
      context: context, backgroundColor: AppConfig.lightNavy,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppConfig.primaryColor), const SizedBox(width: 8),
                const Text("Gemini AI Analysis", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Colors.white10, height: 32),
            _infoRow("Độ tin cậy (Confidence):", "${(ketQuaAI.doTinCay * 100).toStringAsFixed(1)}%", AppConfig.positiveColor),
            const SizedBox(height: 16),
            const Text("Tiêu chí đánh giá:", style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 4),
            Text(ketQuaAI.tieuChiTinCay ?? 'Dựa trên phân tích ngữ nghĩa và cảm xúc từ vựng.', style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
            const SizedBox(height: 16),
            const Text("Lời khuyên (Trích xuất):", style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 4),
            Text(ketQuaAI.lyDoCuaAI ?? 'Không có', style: const TextStyle(color: AppConfig.primaryColor, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.white70)),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
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
            Text(text, style: TextStyle(color: isUser ? AppConfig.primaryColor : Colors.white, fontSize: 16, height: 1.5)),
            if (!isUser && sentiment != 'TRUNG_LAP') ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showExplainDialog(context), // Bấm vào để xem độ tin cậy
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _getSentimentColor().withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: _getSentimentColor().withValues(alpha: 0.3))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: _getSentimentColor(), size: 14), const SizedBox(width: 6),
                      Text(sentiment, style: TextStyle(color: _getSentimentColor(), fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}