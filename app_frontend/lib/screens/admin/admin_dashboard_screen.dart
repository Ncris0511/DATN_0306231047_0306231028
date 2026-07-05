import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_config.dart';
import '../../providers/app_provider.dart';
import '../gateway_screen.dart';
import 'admin_topic_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AppProvider>().taiDuLieuDashboard(),
    );
  }

  // BỘ LỌC THỜI GIAN
  Widget _buildTimeFilters(AppProvider prov, bool isDark) {
    final filters = {
      'hom_nay': 'Hôm nay',
      '7_ngay': 'Tuần này',
      'thang_nay': 'Tháng này',
      'nam_nay': 'Năm nay',
      'tat_ca': 'Tất cả',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((e) {
          final isSelected = prov.boLocThoiGianHienTai == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                e.value,
                style: TextStyle(
                  color: isSelected
                      ? AppConfig.primaryText(isDark)
                      : AppConfig.textSub(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: AppConfig.primary(isDark),
              backgroundColor: AppConfig.inputBg(isDark),
              showCheckmark: false,
              side: BorderSide.none,
              onSelected: (val) {
                if (val) {
                  prov.boLocThoiGianHienTai = e.key;
                  prov.taiDuLieuDashboard();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDarkMode;

    return Scaffold(
      backgroundColor: AppConfig.bg(isDark),
      appBar: AppBar(
        automaticallyImplyLeading: false, // KHÓA NÚT BACK
        title: Row(
          children: [
            Icon(Icons.dashboard_customize, color: AppConfig.primary(isDark)),
            const SizedBox(width: 12),
            Text(
              'Admin Center',
              style: TextStyle(
                color: AppConfig.textMain(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: AppConfig.card(isDark),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppConfig.negativeColor),
            onPressed: () {
              prov.dangXuatAdmin();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const GatewayScreen()),
                (r) => false,
              );
            },
          ),
        ],
      ),
      body: prov.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppConfig.primary(isDark),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeFilters(prov, isDark),
                  const SizedBox(height: 24),
                  if (prov.chiSoNps != null) ...[
                    Text(
                      "Tổng quan Hệ thống",
                      style: TextStyle(
                        color: AppConfig.textMain(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _kpiCard(
                            "Tích cực",
                            prov.chiSoNps!.tichCuc.toString(),
                            AppConfig.positiveColor,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _kpiCard(
                            "Tiêu cực",
                            prov.chiSoNps!.tieuCuc.toString(),
                            AppConfig.negativeColor,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _kpiCard(
                            "Chỉ số NPS",
                            "${prov.chiSoNps!.diemNps}",
                            AppConfig.primary(isDark),
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  Text(
                    "Biểu đồ Cảm xúc",
                    style: TextStyle(
                      color: AppConfig.textMain(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBieuDoThongKe(prov, isDark),
                  const SizedBox(height: 32),
                  Text(
                    "Quản lý Sản phẩm (Chạm để xem chi tiết)",
                    style: TextStyle(
                      color: AppConfig.textMain(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: prov.danhSachChuDe.length,
                    itemBuilder: (ctx, i) {
                      final topic = prov.danhSachChuDe[i];
                      return Card(
                        color: AppConfig.card(isDark),
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppConfig.border(isDark)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            topic.tenChuDe,
                            style: TextStyle(
                              color: AppConfig.textMain(isDark),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${topic.soLuongBinhLuan} bình luận',
                              style: TextStyle(
                                color: AppConfig.textSub(isDark),
                              ),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: topic.phanQuyetAi == 'APPROVED_NEN_MUA'
                                  ? AppConfig.positiveColor.withOpacity(0.1)
                                  : AppConfig.negativeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              topic.phanQuyetAi == 'APPROVED_NEN_MUA'
                                  ? 'NÊN MUA'
                                  : 'CÂN NHẮC',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: topic.phanQuyetAi == 'APPROVED_NEN_MUA'
                                    ? AppConfig.positiveColor
                                    : AppConfig.negativeColor,
                              ),
                            ),
                          ),
                          // ĐẨY VÀO MÀN HÌNH MỚI CHI TIẾT
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminTopicDetailScreen(topic: topic),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBieuDoThongKe(AppProvider prov, bool isDark) {
    if (prov.danhSachDiemThoiGian.isEmpty ||
        prov.danhSachDiemThoiGian.every(
          (e) => e.tichCuc == 0 && e.tieuCuc == 0,
        )) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppConfig.card(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppConfig.border(isDark)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 50,
                color: AppConfig.textSub(isDark).withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                "Chưa có dữ liệu thống kê",
                style: TextStyle(color: AppConfig.textSub(isDark)),
              ),
            ],
          ),
        ),
      );
    }

    double maxY = 10;
    double maxTichCuc = prov.danhSachDiemThoiGian
        .map((e) => e.tichCuc.toDouble())
        .reduce(max);
    double maxTieuCuc = prov.danhSachDiemThoiGian
        .map((e) => e.tieuCuc.toDouble())
        .reduce(max);
    maxY = max(maxTichCuc, maxTieuCuc) + 5;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConfig.border(isDark)),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: prov.danhSachDiemThoiGian
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.tichCuc.toDouble(),
                      color: AppConfig.positiveColor,
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: e.value.tieuCuc.toDouble(),
                      color: AppConfig.negativeColor,
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              )
              .toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: TextStyle(
                    color: AppConfig.textSub(isDark),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  v.toInt() >= 0 && v.toInt() < prov.danhSachDiemThoiGian.length
                      ? prov.danhSachDiemThoiGian[v.toInt()].mox.substring(5)
                      : '',
                  style: TextStyle(
                    color: AppConfig.textSub(isDark),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppConfig.border(isDark), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConfig.border(isDark)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: AppConfig.textSub(isDark), fontSize: 11),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
