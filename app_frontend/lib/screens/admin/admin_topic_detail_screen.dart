import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chu_de_model.dart';
import '../../models/sentiment_result.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_config.dart';

class AdminTopicDetailScreen extends StatefulWidget {
  final ChuDeModel topic;
  const AdminTopicDetailScreen({super.key, required this.topic});
  @override
  State<AdminTopicDetailScreen> createState() => _AdminTopicDetailScreenState();
}

class _AdminTopicDetailScreenState extends State<AdminTopicDetailScreen> {
  bool isLoading = true;
  List<KetQuaAI> history = [];
  int npsScore = 0;
  int tichCuc = 0;
  int tieuCuc = 0;
  double avgStars = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final api = ApiService();
    final data = await api.layChiTietPhienChat(widget.topic.id);
    if (data.isNotEmpty) {
      tichCuc = data.where((e) => e.nhanCamXuc == 'TICH_CUC').length;
      tieuCuc = data.where((e) => e.nhanCamXuc == 'TIEU_CUC').length;
      npsScore = (((tichCuc - tieuCuc) / data.length) * 100).round();

      int totalStars = data.fold(0, (sum, e) => sum + (e.danhGiaSao ?? 0));
      avgStars = totalStars / data.length;
    }
    setState(() {
      history = data;
      isLoading = false;
    });
  }

  // 1. WIDGET CHỈ SỐ NHỎ (TÍCH CỰC, TIÊU CỰC, TỔNG)
  Widget _miniStat(String label, String val, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            color: color,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppConfig.textSub(isDark),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<AppProvider>().isDarkMode;
    final isApproved = widget.topic.phanQuyetAi == 'APPROVED_NEN_MUA';

    return Scaffold(
      backgroundColor: AppConfig.bg(isDark),
      appBar: AppBar(
        title: Text(
          "Giám sát: ${widget.topic.tenChuDe}",
          style: TextStyle(
            color: AppConfig.textMain(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppConfig.card(isDark),
        iconTheme: IconThemeData(color: AppConfig.textMain(isDark)),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppConfig.primary(isDark),
              ),
            )
          : CustomScrollView(
              slivers: [
                // PHẦN HEADER THỐNG KÊ (HERO SECTION)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [Colors.white, const Color(0xFFF8FAFC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppConfig.border(isDark)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "ĐIỂM NPS CỤC BỘ",
                          style: TextStyle(
                            color: AppConfig.textSub(isDark),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$npsScore",
                          style: TextStyle(
                            color: npsScore > 0
                                ? AppConfig.positiveColor
                                : AppConfig.negativeColor,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        // Rating Sao trung bình
                        if (avgStars > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                avgStars.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _miniStat(
                              "Tích cực",
                              tichCuc.toString(),
                              AppConfig.positiveColor,
                              isDark,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppConfig.border(isDark),
                            ),
                            _miniStat(
                              "Tiêu cực",
                              tieuCuc.toString(),
                              AppConfig.negativeColor,
                              isDark,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppConfig.border(isDark),
                            ),
                            _miniStat(
                              "Tổng",
                              history.length.toString(),
                              AppConfig.primary(isDark),
                              isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Phán quyết của AI
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isApproved
                                ? AppConfig.positiveColor.withOpacity(0.08)
                                : AppConfig.negativeColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isApproved
                                  ? AppConfig.positiveColor.withOpacity(0.3)
                                  : AppConfig.negativeColor.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isApproved
                                        ? Icons.verified_rounded
                                        : Icons.warning_rounded,
                                    color: isApproved
                                        ? AppConfig.positiveColor
                                        : AppConfig.negativeColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "AI KHUYẾN NGHỊ: ${isApproved ? 'NÊN MUA' : 'CÂN NHẮC'}",
                                    style: TextStyle(
                                      color: isApproved
                                          ? AppConfig.positiveColor
                                          : AppConfig.negativeColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.topic.tomTatAi ??
                                    'Chưa có dữ liệu hội chẩn',
                                style: TextStyle(
                                  color: AppConfig.textMain(isDark),
                                  height: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // DANH SÁCH BÌNH LUẬN (HIỂN THỊ ĐỦ SAO VÀ KHÍA CẠNH)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 8),
                      child: Text(
                        "CHI TIẾT LOG PHÂN TÍCH",
                        style: TextStyle(
                          color: AppConfig.textSub(isDark),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 40,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, i) {
                      final kq = history[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppConfig.card(isDark),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppConfig.border(isDark)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar + Noi dung khach hang
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppConfig.primary(
                                    isDark,
                                  ).withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    size: 18,
                                    color: AppConfig.primary(isDark),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Khách hàng ${i + 1}',
                                        style: TextStyle(
                                          color: AppConfig.textSub(isDark),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '"${kq.noiDung}"',
                                        style: TextStyle(
                                          color: AppConfig.textMain(isDark),
                                          fontSize: 15,
                                          height: 1.4,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (kq.nhanCamXuc != 'CHUA_PHAN_LOAI') ...[
                              const SizedBox(height: 20),
                              Divider(
                                color: AppConfig.border(isDark),
                                height: 1,
                              ),
                              const SizedBox(height: 16),

                              // Phân tích Cảm xúc & Tin cậy
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kq.nhanCamXuc == 'TICH_CUC'
                                          ? AppConfig.positiveColor.withOpacity(
                                              0.1,
                                            )
                                          : AppConfig.negativeColor.withOpacity(
                                              0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          kq.nhanCamXuc == 'TICH_CUC'
                                              ? Icons.thumb_up_alt_rounded
                                              : Icons.thumb_down_alt_rounded,
                                          color: kq.nhanCamXuc == 'TICH_CUC'
                                              ? AppConfig.positiveColor
                                              : AppConfig.negativeColor,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          kq.nhanCamXuc,
                                          style: TextStyle(
                                            color: kq.nhanCamXuc == 'TICH_CUC'
                                                ? AppConfig.positiveColor
                                                : AppConfig.negativeColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "Tin cậy: ${(kq.doTinCay * 100).toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      color: kq.doTinCay > 0.7
                                          ? AppConfig.positiveColor
                                          : AppConfig.neutralColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Lý do AI và Số Sao
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppConfig.inputBg(isDark),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Chấm điểm: ",
                                          style: TextStyle(
                                            color: AppConfig.textMain(isDark),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (index) => Icon(
                                              index < (kq.danhGiaSao ?? 0)
                                                  ? Icons.star_rounded
                                                  : Icons.star_outline_rounded,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Lý do: ${kq.lyDoDanhGiaSao != null && kq.lyDoDanhGiaSao.toString().isNotEmpty ? kq.lyDoDanhGiaSao : kq.lyDoCuaAI}",
                                      style: TextStyle(
                                        color: AppConfig.textSub(isDark),
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Khía cạnh phân tích (Aspects)
                              if (kq.danhSachKhiaCanh != null &&
                                  kq.danhSachKhiaCanh.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: kq.danhSachKhiaCanh.map<Widget>((
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
                                        color: AppConfig.bg(isDark),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: kcColor.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            kc.nhanCamXuc == 'TICH_CUC'
                                                ? Icons.add_circle
                                                : (kc.nhanCamXuc == 'TIEU_CUC'
                                                      ? Icons.remove_circle
                                                      : Icons
                                                            .radio_button_unchecked),
                                            size: 12,
                                            color: kcColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            kc.tenKhiaCanh,
                                            style: TextStyle(
                                              color: kcColor,
                                              fontSize: 11,
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
                          ],
                        ),
                      );
                    }, childCount: history.length),
                  ),
                ),
              ],
            ),
    );
  }
}
