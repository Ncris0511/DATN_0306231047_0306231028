import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:open_file/open_file.dart';

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
    String clean = hexString.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
    if (clean.length == 6) clean = 'FF$clean';
    try {
      return Color(int.parse(clean, radix: 16));
    } catch (e) {
      return AppConfig.primaryColor;
    }
  }

  void _dangXuat() {
    context.read<AppProvider>().dangXuatAdmin();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const GatewayScreen()),
      (route) => false,
    );
  }

  Future<void> _taiBaoCaoExcel() async {
    final api = ApiService();
    final path = await api.taiFileBaoCaoExcel();
    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã tải xuống: $path'), backgroundColor: AppConfig.positiveColor));
      OpenFile.open(path);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi tải báo cáo!'), backgroundColor: AppConfig.negativeColor));
    }
  }

  Widget _buildFilterChip(String label, String key, AppProvider prov) {
    final isSelected = prov.boLocThoiGianHienTai == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppConfig.darkNavy, fontWeight: FontWeight.bold, fontSize: 12)),
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
            Container(width: double.infinity, height: 260, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
            const SizedBox(height: 20),
            Container(width: double.infinity, height: 220, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final nps = prov.chiSoNps;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Admin Portal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppConfig.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _taiBaoCaoExcel),
          IconButton(icon: const Icon(Icons.logout), onPressed: _dangXuat),
        ],
      ),
      body: prov.isLoading || nps == null
          ? _buildShimmerLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _parseHexColor(nps.mauSacUi),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text('Net Promoter Score (NPS)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('${nps.diemNps}', style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)),
                        Text(nps.chanDoan, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Hôm nay', 'hom_nay', prov),
                        _buildFilterChip('7 Ngày', '7_ngay', prov),
                        _buildFilterChip('Tháng này', 'thang_nay', prov),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Biểu đồ xu hướng (Tích cực vs Tiêu cực)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConfig.darkNavy)),
                  const SizedBox(height: 12),
                  if (prov.danhSachDiemThoiGian.isNotEmpty)
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: prov.danhSachDiemThoiGian.map((e) => e.tongSo.toDouble()).reduce((a, b) => a > b ? a : b) + 5,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 && value.toInt() < prov.danhSachDiemThoiGian.length) {
                                    return Text(prov.danhSachDiemThoiGian[value.toInt()].mox, style: const TextStyle(fontSize: 10));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: prov.danhSachDiemThoiGian.asMap().entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(toY: e.value.tichCuc.toDouble(), color: AppConfig.positiveColor, width: 12),
                                BarChartRodData(toY: e.value.tieuCuc.toDouble(), color: AppConfig.negativeColor, width: 12),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    const Center(child: Text('Không có dữ liệu cho miền thời gian này')),
                ],
              ),
            ),
    );
  }
}