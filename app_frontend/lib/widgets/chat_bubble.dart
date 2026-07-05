import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String sentiment;
  final dynamic ketQuaAI;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.sentiment,
    this.ketQuaAI,
  });

  Color _getSentimentColor() {
    if (sentiment == 'TICH_CUC') return AppConfig.positiveColor;
    if (sentiment == 'TIEU_CUC') return AppConfig.negativeColor;
    return AppConfig.neutralColor;
  }

  // Dịch điểm sao sang đánh giá để bảo vệ trước Hội đồng
  String _getStarLabel(int sao) {
    switch (sao) {
      case 5:
        return "Cực kỳ hài lòng";
      case 4:
        return "Hài lòng";
      case 3:
        return "Bình thường / Trung lập";
      case 2:
        return "Không hài lòng";
      case 1:
        return "Rất thất vọng";
      default:
        return "Chưa xác định";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().isDarkMode;

    // GIAO DIỆN BONG BÓNG CỦA KHÁCH (MÀU XANH BÊN PHẢI)
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppConfig.primary(isDark),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppConfig.primaryText(isDark),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
      );
    }
    // GIAO DIỆN BONG BÓNG CỦA AI (MÀU NHẠT BÊN TRÁI CHỨA PHÂN TÍCH)
    else {
      return Padding(
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 24,
          left: 16,
          right: 24,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Avatar AI
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppConfig.primary(isDark).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: AppConfig.primary(isDark),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Nội dung phân tích
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SentiFlow AI",
                    style: TextStyle(
                      color: AppConfig.textMain(isDark),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    text.isEmpty
                        ? "Tôi đã tiếp nhận và xử lý bình luận này. Dưới đây là kết quả giám định:"
                        : text,
                    style: TextStyle(
                      color: AppConfig.textMain(isDark),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Lời giải thích ngắn của AI
                  Text(
                    ketQuaAI?.lyDoCuaAI ?? 'Đang xử lý...',
                    style: TextStyle(
                      color: AppConfig.primary(isDark),
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  // Khối Căn cứ độ tin cậy
                  if (ketQuaAI != null &&
                      ketQuaAI.tieuChiTinCay != null &&
                      ketQuaAI.tieuChiTinCay.toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConfig.card(isDark),
                        border: Border(
                          left: BorderSide(
                            color: AppConfig.border(isDark),
                            width: 4,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Căn cứ giám định:",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppConfig.textSub(isDark),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ketQuaAI.tieuChiTinCay,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppConfig.textMain(isDark),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Bảng Phân tích Chi tiết (Thanh Cảm xúc, Điểm Sao, Khía cạnh)
                  if (sentiment != 'CHUA_PHAN_LOAI' && ketQuaAI != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConfig.card(isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConfig.border(isDark)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. THANH CẢM XÚC (PROGRESS BAR)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    sentiment == 'TICH_CUC'
                                        ? Icons.thumb_up_alt
                                        : sentiment == 'TIEU_CUC'
                                        ? Icons.thumb_down_alt
                                        : Icons.remove_circle,
                                    color: _getSentimentColor(),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    sentiment,
                                    style: TextStyle(
                                      color: _getSentimentColor(),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Tin cậy: ${(ketQuaAI.doTinCay * 100).toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: ketQuaAI.doTinCay > 0.7
                                      ? AppConfig.positiveColor
                                      : (ketQuaAI.doTinCay > 0.4
                                            ? AppConfig.neutralColor
                                            : AppConfig.negativeColor),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ketQuaAI.doTinCay,
                              minHeight: 6,
                              backgroundColor: AppConfig.border(isDark),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ketQuaAI.doTinCay > 0.7
                                    ? AppConfig.positiveColor
                                    : (ketQuaAI.doTinCay > 0.4
                                          ? AppConfig.neutralColor
                                          : AppConfig.negativeColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: AppConfig.border(isDark), height: 1),
                          const SizedBox(height: 12),

                          // 2. HIỂN THỊ ĐÁNH GIÁ SAO VÀ BẰNG CHỨNG (LY DO SAO) BẢO VỆ TRƯỚC HỘI ĐỒNG
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppConfig.inputBg(isDark),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Chuyển đổi thang điểm: ",
                                      style: TextStyle(
                                        color: AppConfig.textMain(isDark),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < (ketQuaAI.danhGiaSao ?? 0)
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  (ketQuaAI.lyDoDanhGiaSao != null &&
                                          ketQuaAI.lyDoDanhGiaSao
                                              .toString()
                                              .isNotEmpty)
                                      ? "Căn cứ chấm sao: ${ketQuaAI.lyDoDanhGiaSao}"
                                      : "Căn cứ chấm sao: Quy chiếu mức độ '${_getStarLabel(ketQuaAI.danhGiaSao ?? 0).toLowerCase()}' dựa trên cường độ cảm xúc.",
                                  style: TextStyle(
                                    color: AppConfig.textSub(isDark),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 3. HIỂN THỊ CÁC KHÍA CẠNH (ASPECTS CHIPS)
                          if (ketQuaAI.danhSachKhiaCanh != null &&
                              ketQuaAI.danhSachKhiaCanh.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              "Phân tích Đa Khía Cạnh:",
                              style: TextStyle(
                                color: AppConfig.textSub(isDark),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ketQuaAI.danhSachKhiaCanh.map<Widget>((
                                kc,
                              ) {
                                Color kcColor = kc.nhanCamXuc == 'TICH_CUC'
                                    ? AppConfig.positiveColor
                                    : (kc.nhanCamXuc == 'TIEU_CUC'
                                          ? AppConfig.negativeColor
                                          : AppConfig.neutralColor);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kcColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: kcColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        kc.nhanCamXuc == 'TICH_CUC'
                                            ? Icons.arrow_upward
                                            : (kc.nhanCamXuc == 'TIEU_CUC'
                                                  ? Icons.arrow_downward
                                                  : Icons.remove),
                                        size: 12,
                                        color: kcColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        kc.tenKhiaCanh,
                                        style: TextStyle(
                                          color: kcColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
