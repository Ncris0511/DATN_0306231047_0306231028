import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';

import '../utils/app_config.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import 'gateway_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().taiDuLieuDashboard();
    });
  }

  Color _parseHexColor(String hexString) {
    String clean = hexString
        .replaceAll('#', '')
        .replaceAll('0x', '')
        .replaceAll('0X', '');
    if (clean.length == 6) clean = 'FF$clean';
    try {
      return Color(int.parse(clean, radix: 16));
    } catch (e) {
      return AppConfig.primaryColor;
    }
  }

  // ⚠️ GIAO DIỆN THÔNG BÁO EXCEL MỚI (HỖ TRỢ COPY LINK TRỰC TIẾP):
  Future<void> _kichHoatTaiExcel(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(strokeWidth: 3),
                SizedBox(height: 20),
                Text(
                  'Đang kết xuất báo cáo Excel...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppConfig.darkNavy,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Vui lòng không tắt ứng dụng',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final savePath = await ApiService().publicDownloadPath;
      final downloadLink = ApiService().urlXuatExcel;

      await Dio().download(downloadLink, savePath);

      if (!context.mounted) return;
      Navigator.pop(context);

      final openResult = await OpenFile.open(savePath);

      // Bắn VIP Toast có thể bôi đen copy link:
      if (openResult.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'KẾT XUẤT TỆP THÀNH CÔNG!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mẹo mở file siêu tốc: Mở trình duyệt Safari/Chrome trên Mac, dán link sau:',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                // ⚠️ Cho phép admin bấm đúp copy link dán ra Mac:
                SelectableText(
                  'http://localhost:3000/api/admin/xuat-bao-cao',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0D1B2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            elevation: 12,
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải tệp: $e'),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final nps = appProvider.chiSoNps;
    final danhSach = appProvider.danhSachDiemThoiGian;
    final liveFeed = appProvider.danhSachBinhLuan;

    return Scaffold(
      backgroundColor: AppConfig.bgCard,
      appBar: AppBar(
        backgroundColor: AppConfig.darkNavy,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppConfig.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'BẢNG ĐIỀU KHIỂN AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await appProvider.dangXuatAdmin();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const GatewayScreen()),
                (r) => false,
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 16,
            ),
            label: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: appProvider.isLoading && nps == null
          ? _buildShimmerLoading()
          : SafeArea(
              child: RefreshIndicator(
                color: AppConfig.primaryColor,
                onRefresh: () async => await appProvider.taiDuLieuDashboard(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Xin chào, ${appProvider.adminUser?['ho_ten'] ?? 'Quản trị viên'}!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConfig.darkNavy,
                            ),
                          ),
                          IconButton(
                            onPressed: () => appProvider.taiDuLieuDashboard(),
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppConfig.primaryColor,
                            ),
                            tooltip: 'Làm mới dữ liệu',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (nps != null)
                        Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          color: _parseHexColor(nps.mauSacUi),
                          shadowColor: _parseHexColor(
                            nps.mauSacUi,
                          ).withValues(alpha: 0.4),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Text(
                                  'CHỈ SỐ NET PROMOTER SCORE (NPS)',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  nps.diemNps > 0
                                      ? '+${nps.diemNps}'
                                      : '${nps.diemNps}',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1.5,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    nps.chanDoan,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildFrostedCapsule(
                                      'TÍCH CỰC',
                                      '${nps.tichCuc}',
                                      AppConfig.positiveColor,
                                    ),
                                    _buildFrostedCapsule(
                                      'TRUNG LẬP',
                                      '${nps.trungLap}',
                                      AppConfig.neutralColor,
                                    ),
                                    _buildFrostedCapsule(
                                      'TIÊU CỰC',
                                      '${nps.tieuCuc}',
                                      AppConfig.negativeColor,
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.white24,
                                  height: 24,
                                ),
                                Text(
                                  'Dựa trên tổng số ${nps.tongBinhLuan} văn bản đã quét AI',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),

                      const Text(
                        'Biến động tần suất AI kiểm duyệt:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterBtn(appProvider, 'hom_nay', 'Hôm nay'),
                            _buildFilterBtn(appProvider, '7_ngay', '7 Ngày'),
                            _buildFilterBtn(
                              appProvider,
                              'thang_nay',
                              'Tháng này',
                            ),
                            _buildFilterBtn(appProvider, 'nam_nay', 'Năm nay'),
                            _buildFilterBtn(appProvider, 'tat_ca', 'Tất cả'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Card(
                        color: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 24,
                            right: 24,
                            left: 12,
                            bottom: 16,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppConfig.positiveColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Tích cực',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppConfig.negativeColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Tiêu cực',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                height: 240,
                                child: danhSach.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'Chưa phát sinh dữ liệu cột',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY:
                                              danhSach
                                                  .fold<int>(
                                                    1,
                                                    (p, c) => c.tongSo > p
                                                        ? c.tongSo
                                                        : p,
                                                  )
                                                  .toDouble() +
                                              1,
                                          barTouchData: BarTouchData(
                                            enabled: true,
                                            touchTooltipData: BarTouchTooltipData(
                                              getTooltipColor: (_) =>
                                                  Colors.black87,
                                              tooltipMargin: 8,
                                              getTooltipItem:
                                                  (
                                                    group,
                                                    groupIndex,
                                                    rod,
                                                    rodIndex,
                                                  ) {
                                                    final isPos = rodIndex == 0;
                                                    return BarTooltipItem(
                                                      '${isPos ? "Tích cực" : "Tiêu cực"}: ${rod.toY.toInt()}',
                                                      TextStyle(
                                                        color: isPos
                                                            ? Colors
                                                                  .green
                                                                  .shade400
                                                            : Colors
                                                                  .red
                                                                  .shade400,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 30,
                                                getTitlesWidget: (v, _) {
                                                  final idx = v.toInt();
                                                  if (idx < 0 ||
                                                      idx >= danhSach.length)
                                                    return const SizedBox();
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8.0,
                                                        ),
                                                    child: Text(
                                                      danhSach[idx].mox,
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 28,
                                                getTitlesWidget: (v, _) => Text(
                                                  '${v.toInt()}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            getDrawingHorizontalLine: (_) =>
                                                FlLine(
                                                  color: Colors.grey.shade200,
                                                  strokeWidth: 1,
                                                ),
                                          ),
                                          borderData: FlBorderData(show: false),
                                          barGroups: danhSach.asMap().entries.map((
                                            e,
                                          ) {
                                            final item = e.value;
                                            return BarChartGroupData(
                                              x: e.key,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: item.tichCuc.toDouble(),
                                                  color:
                                                      AppConfig.positiveColor,
                                                  width: 10,
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(4),
                                                      ),
                                                ),
                                                BarChartRodData(
                                                  toY: item.tieuCuc.toDouble(),
                                                  color:
                                                      AppConfig.negativeColor,
                                                  width: 10,
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(4),
                                                      ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // =======================================================
                      // ⚠️ GIAO DIỆN BÌNH LUẬN V6 (HIỂN THỊ CẢ LÝ DO CỦA AI)
                      // =======================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Luồng văn bản kiểm duyệt AI:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppConfig.darkNavy,
                            ),
                          ),
                          Text(
                            '${liveFeed.length} mục gần đây',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      liveFeed.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.comments_disabled_outlined,
                                    size: 36,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Chưa trích xuất được gói tin thô từ MySQL',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: liveFeed.length > 20
                                  ? 20
                                  : liveFeed.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = liveFeed[index];
                                final isPos = item.nhanCamXuc == 'TICH_CUC';
                                final isNeg = item.nhanCamXuc == 'TIEU_CUC';
                                final bColor = isPos
                                    ? AppConfig.positiveColor
                                    : (isNeg
                                          ? AppConfig.negativeColor
                                          : AppConfig.neutralColor);
                                final bText = isPos
                                    ? 'TÍCH CỰC'
                                    : (isNeg ? 'TIÊU CỰC' : 'TRUNG LẬP');

                                return Card(
                                  color: Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: bColor.withValues(
                                                      alpha: 0.15,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    bText,
                                                    style: TextStyle(
                                                      color: bColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Row(
                                                  children: List.generate(
                                                    5,
                                                    (s) => Icon(
                                                      s < item.danhGiaSao
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${(item.doTinCay * 100).toInt()}% AI',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade400,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          item.noiDung,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppConfig.darkNavy,
                                            fontWeight: FontWeight.bold,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // ⚠️ CẤY RÕ RÀNG LÝ DO GEMINI BÓC TÁCH:
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Text(
                                            'AI lập luận: ${item.lyDoCuaAI}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade800,
                                              fontStyle: FontStyle.italic,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _kichHoatTaiExcel(context),
        backgroundColor: AppConfig.darkNavy,
        elevation: 8,
        icon: const Icon(Icons.file_download_rounded, color: Colors.white),
        label: const Text(
          'KẾT XUẤT BÁO CÁO EXCEL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFrostedCapsule(String label, String val, Color dotColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  val,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBtn(AppProvider prov, String key, String label) {
    final isSelected = prov.boLocThoiGianHienTai == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppConfig.darkNavy,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        selectedColor: AppConfig.primaryColor,
        backgroundColor: Colors.grey.shade200,
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (_) => prov.thayDoiMienThoiGian(key),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 20),
            Container(width: 180, height: 20, color: Colors.white),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
