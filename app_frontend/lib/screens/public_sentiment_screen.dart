import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';

class PublicSentimentScreen extends StatefulWidget {
  const PublicSentimentScreen({super.key});

  @override
  State<PublicSentimentScreen> createState() => _PublicSentimentScreenState();
}

class _PublicSentimentScreenState extends State<PublicSentimentScreen> {
  final TextEditingController _noiDungController = TextEditingController();

  // Bộ 3 câu kỹ xảo thao túng thời gian chờ (chu kỳ lướt 1.2s):
  final List<String> _cacCauCho = [
    "SentiFlow đang đóng gói gói tin gửi lên Google Cloud...",
    "Mạng Nơ-ron Gemini đang phân rã trọng số từ vựng...",
    "Đang trích xuất minh chứng Explainable AI (XAI)...",
  ];

  @override
  void dispose() {
    _noiDungController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final kq = appProvider.ketQuaHienTai;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConfig.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Thẩm Định Cảm Xúc AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConfig.darkNavy, AppConfig.lightNavy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =============================================================
                // KHUNG NHẬP LIỆU BỌC THÉP
                // =============================================================
                const Text(
                  'Nhập nội dung văn bản cần kiểm duyệt:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _noiDungController,
                          maxLines: 6,
                          maxLength: 500,
                          enabled: !appProvider
                              .isLoading, // Đang load là khóa chết không cho gõ bồi
                          decoration: const InputDecoration(
                            hintText:
                                'Ví dụ: Máy xài rất mượt, giao hàng nhanh nhưng hộp đóng gói bị móp nhẹ...',
                            border: InputBorder.none,
                            counterText:
                                '', // Tắt bộ đếm mặc định để xài bộ đếm custom bên dưới
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${_noiDungController.text.length} / 500 ký tự',
                            style: TextStyle(
                              color: _noiDungController.text.length > 480
                                  ? Colors.red
                                  : Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // =============================================================
                // NÚT PHÁT ĐỘNG API GEMINI
                // =============================================================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        appProvider.isLoading ||
                            _noiDungController.text.trim().isEmpty
                        ? null
                        : () async {
                            FocusScope.of(
                              context,
                            ).unfocus(); // Thu bàn phím xuống
                            appProvider.guiBinhLuanPhanTich(
                              _noiDungController.text,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 6,
                    ),
                    child: appProvider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'PHÂN TÍCH BẰNG AI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // =============================================================
                // KỸ XẢO LOADING GIẢ LẬP (SHIMMER SKELETON)
                // =============================================================
                if (appProvider.isLoading)
                  Center(
                    child: Column(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.white.withOpacity(0.15),
                          highlightColor: Colors.white.withOpacity(0.4),
                          child: Container(
                            width: double.infinity,
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Khối Text múa may lừa giác quan:
                        StreamBuilder(
                          stream: Stream.periodic(
                            const Duration(milliseconds: 1200),
                            (i) => i,
                          ),
                          builder: (context, snapshot) {
                            final step =
                                (snapshot.data ?? 0) % _cacCauCho.length;
                            return Text(
                              _cacCauCho[step],
                              style: const TextStyle(
                                color: AppConfig.primaryColor,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                // =============================================================
                // BẪY HIỂN THỊ LỖI (NẾU CÓ)
                // =============================================================
                if (appProvider.errorMessage != null && !appProvider.isLoading)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            appProvider.errorMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // =============================================================
                // TRÌNH DIỄN KẾT QUẢ XAI (GIẢI MÃ KHUÔN KetQuaAI)
                // =============================================================
                if (kq != null && !appProvider.isLoading) ...[
                  const Text(
                    'Kết Quả Thẩm Định:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hàng 1: Nhãn Cảm xúc + Độ tin cậy
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: kq.nhanCamXuc == 'TICH_CUC'
                                      ? AppConfig.positiveColor
                                      : (kq.nhanCamXuc == 'TIEU_CUC'
                                            ? AppConfig.negativeColor
                                            : AppConfig.neutralColor),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  kq.nhanCamXuc == 'TICH_CUC'
                                      ? 'TÍCH CỰC'
                                      : (kq.nhanCamXuc == 'TIEU_CUC'
                                            ? 'TIÊU CỰC'
                                            : 'TRUNG LẬP'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                'Độ tin cậy: ${(kq.doTinCay * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Hàng 2: Render Dải Sao Vàng
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: kq.danhGiaSao.toDouble(),
                                itemBuilder: (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 22.0,
                                direction: Axis.horizontal,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '(${kq.mucDoHaiLong})',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(),
                          ),

                          // Hàng 3: BÌNH DUYỆT XAI (LÝ DO CỦA GEMINI)
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 18,
                                color: AppConfig.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Lập luận Explainable AI (XAI):',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppConfig.darkNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppConfig.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppConfig.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: SelectableText(
                              kq.lyDoCuaAI,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Hàng 4: Thông tin trinh sát Model
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Model: ${kq.aiVersion}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Thời gian suy luận: ${kq.thoiGianMs}ms',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
