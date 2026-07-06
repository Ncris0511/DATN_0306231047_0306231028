import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
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
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(
                e.value,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppConfig.textSub(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: AppConfig.primary(isDark),
              backgroundColor: AppConfig.inputBg(isDark),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _kpiCard(
    String title,
    String value,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConfig.border(isDark).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 60, color: color.withOpacity(0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppConfig.textSub(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: AppConfig.textMain(isDark),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- BIỂU ĐỒ 1: DONUT CHART ---
  Widget _buildDonutChart(AppProvider prov, bool isDark) {
    int tichCuc = prov.chiSoNps?.tichCuc ?? 0,
        tieuCuc = prov.chiSoNps?.tieuCuc ?? 0,
        trungLap = prov.chiSoNps?.trungLap ?? 0;
    int tongSo = prov.chiSoNps?.tongSo ?? 0;
    if (tongSo == 0) return _emptyChartContainer(isDark);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConfig.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConfig.border(isDark)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 55,
                    sections: [
                      if (tichCuc > 0)
                        PieChartSectionData(
                          color: AppConfig.positiveColor,
                          value: tichCuc.toDouble(),
                          title: '$tichCuc',
                          radius: 22,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (tieuCuc > 0)
                        PieChartSectionData(
                          color: AppConfig.negativeColor,
                          value: tieuCuc.toDouble(),
                          title: '$tieuCuc',
                          radius: 22,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (trungLap > 0)
                        PieChartSectionData(
                          color: AppConfig.neutralColor,
                          value: trungLap.toDouble(),
                          title: '$trungLap',
                          radius: 22,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Tổng số",
                      style: TextStyle(
                        color: AppConfig.textSub(isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$tongSo",
                      style: TextStyle(
                        color: AppConfig.textMain(isDark),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem("Tích cực", AppConfig.positiveColor, isDark),
              _buildLegendItem("Tiêu cực", AppConfig.negativeColor, isDark),
              _buildLegendItem("Trung lập", AppConfig.neutralColor, isDark),
            ],
          ),
        ],
      ),
    );
  }

  // --- BIỂU ĐỒ 2: LINE CHART ---
  Widget _buildLineChart(AppProvider prov, bool isDark) {
    if (prov.danhSachDiemThoiGian.isEmpty) return _emptyChartContainer(isDark);
    if (prov.danhSachDiemThoiGian.length == 1) return _singleDayWarning(isDark);

    final spots = prov.danhSachDiemThoiGian.asMap().entries.map((e) {
      final total = e.value.tichCuc + e.value.tieuCuc + e.value.trungLap;
      return FlSpot(e.key.toDouble(), total.toDouble());
    }).toList();
    double maxY = spots.isEmpty ? 10 : spots.map((e) => e.y).reduce(max) + 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: AppConfig.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConfig.border(isDark)),
      ),
      child: Column(
        children: [
          Text(
            "Tổng Tương Tác / Bình Luận",
            style: TextStyle(
              color: AppConfig.textMain(isDark),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blueAccent.withOpacity(0.15),
                    ),
                    dotData: const FlDotData(show: true),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        if (v % 1 != 0) return const SizedBox.shrink();
                        return Text(
                          v.toInt().toString(),
                          style: TextStyle(
                            color: AppConfig.textSub(isDark),
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),

                  // ÁP DỤNG BIỆN PHÁP BỌC THÉP TRỤC X
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (v, meta) {
                        if (v % 1 != 0) return const SizedBox.shrink();
                        int index = v.toInt();
                        if (index >= 0 &&
                            index < prov.danhSachDiemThoiGian.length) {
                          return Transform.rotate(
                            angle: -0.5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                prov.danhSachDiemThoiGian[index].thoiGian,
                                style: TextStyle(
                                  color: AppConfig.textSub(isDark),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppConfig.border(isDark),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BIỂU ĐỒ 3: BAR CHART ---
  Widget _buildBarChart(AppProvider prov, bool isDark) {
    if (prov.danhSachDiemThoiGian.isEmpty ||
        prov.danhSachDiemThoiGian.every(
          (e) => e.tichCuc == 0 && e.tieuCuc == 0,
        ))
      return _emptyChartContainer(isDark);
    double maxY =
        max(
          prov.danhSachDiemThoiGian
              .map((e) => e.tichCuc.toDouble())
              .reduce(max),
          prov.danhSachDiemThoiGian
              .map((e) => e.tieuCuc.toDouble())
              .reduce(max),
        ) +
        2;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: AppConfig.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConfig.border(isDark)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem("Tích cực", AppConfig.positiveColor, isDark),
              const SizedBox(width: 24),
              _buildLegendItem("Tiêu cực", AppConfig.negativeColor, isDark),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
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
                            width: 12,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: e.value.tieuCuc.toDouble(),
                            color: AppConfig.negativeColor,
                            width: 12,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        if (v % 1 != 0) return const SizedBox.shrink();
                        return Text(
                          v.toInt().toString(),
                          style: TextStyle(
                            color: AppConfig.textSub(isDark),
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),

                  // ÁP DỤNG BIỆN PHÁP BỌC THÉP TRỤC X
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (v, meta) {
                        if (v % 1 != 0) return const SizedBox.shrink();
                        int index = v.toInt();
                        if (index >= 0 &&
                            index < prov.danhSachDiemThoiGian.length) {
                          return Transform.rotate(
                            angle: -0.5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                prov.danhSachDiemThoiGian[index].thoiGian,
                                style: TextStyle(
                                  color: AppConfig.textSub(isDark),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppConfig.border(isDark),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyChartContainer(bool isDark) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppConfig.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConfig.border(isDark)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 48,
              color: AppConfig.textSub(isDark).withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "Không có dữ liệu",
              style: TextStyle(color: AppConfig.textSub(isDark), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _singleDayWarning(bool isDark) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppConfig.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConfig.border(isDark)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stacked_line_chart_rounded,
              size: 40,
              color: AppConfig.textSub(isDark).withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "Cần ít nhất 2 mốc để vẽ đường thẳng",
              style: TextStyle(
                color: AppConfig.textSub(isDark),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Vui lòng chọn 'Tuần này' hoặc 'Tháng này'",
              style: TextStyle(color: AppConfig.textSub(isDark), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppConfig.textSub(isDark),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDarkMode;

    return Scaffold(
      backgroundColor: AppConfig.bg(isDark),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppConfig.primary(isDark).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.dashboard_customize_rounded,
                color: AppConfig.primary(isDark),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Admin Center',
              style: TextStyle(
                color: AppConfig.textMain(isDark),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: AppConfig.bg(isDark),
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.file_download_rounded,
                color: Colors.green,
                size: 22,
              ),
            ),
            tooltip: 'Tải Báo cáo Excel',
            onPressed: () async {
              final url = Uri.parse('${AppConfig.baseUrl}/admin/xuat-bao-cao');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không thể mở liên kết tải file!'),
                    ),
                  );
              }
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppConfig.negativeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.power_settings_new_rounded,
                color: AppConfig.negativeColor,
                size: 20,
              ),
            ),
            onPressed: () {
              prov.dangXuatAdmin();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const GatewayScreen()),
                (r) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: prov.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppConfig.primary(isDark),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => await prov.taiDuLieuDashboard(),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  _buildTimeFilters(prov, isDark),
                  const SizedBox(height: 32),

                  Text(
                    "HIỆU SUẤT TỔNG THỂ",
                    style: TextStyle(
                      color: AppConfig.textSub(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _kpiCard(
                        "Tích cực",
                        (prov.chiSoNps?.tichCuc ?? 0).toString(),
                        AppConfig.positiveColor,
                        Icons.thumb_up_rounded,
                        isDark,
                      ),
                      _kpiCard(
                        "Tiêu cực",
                        (prov.chiSoNps?.tieuCuc ?? 0).toString(),
                        AppConfig.negativeColor,
                        Icons.thumb_down_rounded,
                        isDark,
                      ),
                      _kpiCard(
                        "Trung lập",
                        (prov.chiSoNps?.trungLap ?? 0).toString(),
                        AppConfig.neutralColor,
                        Icons.remove_circle_rounded,
                        isDark,
                      ),
                      _kpiCard(
                        "Chỉ số NPS",
                        "${prov.chiSoNps?.diemNps ?? 0}",
                        AppConfig.primary(isDark),
                        Icons.speed_rounded,
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  Text(
                    "BIỂU ĐỒ 1: TỶ LỆ PHÂN BỔ CẢM XÚC",
                    style: TextStyle(
                      color: AppConfig.textSub(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDonutChart(prov, isDark),
                  const SizedBox(height: 36),

                  Text(
                    "BIỂU ĐỒ 2: XU HƯỚNG TƯƠNG TÁC",
                    style: TextStyle(
                      color: AppConfig.textSub(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLineChart(prov, isDark),
                  const SizedBox(height: 36),

                  Text(
                    "BIỂU ĐỒ 3: SO SÁNH CẢM XÚC",
                    style: TextStyle(
                      color: AppConfig.textSub(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBarChart(prov, isDark),
                  const SizedBox(height: 36),

                  Text(
                    "QUẢN LÝ SẢN PHẨM PHÂN TÍCH",
                    style: TextStyle(
                      color: AppConfig.textSub(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (prov.danhSachChuDe.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppConfig.card(isDark),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Không có sản phẩm nào trong thời gian này',
                          style: TextStyle(color: AppConfig.textSub(isDark)),
                        ),
                      ),
                    ),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: prov.danhSachChuDe.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final topic = prov.danhSachChuDe[i];
                      final isApproved =
                          topic.phanQuyetAi == 'APPROVED_NEN_MUA';
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminTopicDetailScreen(topic: topic),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppConfig.card(isDark),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppConfig.border(isDark)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.015),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppConfig.inputBg(isDark),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.inventory_2_rounded,
                                  color: AppConfig.primary(isDark),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topic.tenChuDe,
                                      style: TextStyle(
                                        color: AppConfig.textMain(isDark),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.forum_rounded,
                                          size: 14,
                                          color: AppConfig.textSub(isDark),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${topic.soLuongBinhLuan} bình luận',
                                          style: TextStyle(
                                            color: AppConfig.textSub(isDark),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isApproved
                                      ? AppConfig.positiveColor.withOpacity(0.1)
                                      : AppConfig.negativeColor.withOpacity(
                                          0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  isApproved ? 'NÊN MUA' : 'CẢNH BÁO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: isApproved
                                        ? AppConfig.positiveColor
                                        : AppConfig.negativeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
