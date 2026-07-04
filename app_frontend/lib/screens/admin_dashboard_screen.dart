import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppProvider>().taiDuLieuDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppConfig.darkNavy,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConfig.lightNavy,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), 
            onPressed: () {
              prov.dangXuatAdmin();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const GatewayScreen()), (r) => false);
            }
          )
        ],
      ),
      body: prov.isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppConfig.primaryColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Cards
                if (prov.chiSoNps != null) Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _kpiCard("Tích cực", prov.chiSoNps!.tichCuc.toString(), AppConfig.positiveColor),
                    _kpiCard("Tiêu cực", prov.chiSoNps!.tieuCuc.toString(), AppConfig.negativeColor),
                    _kpiCard("NPS", prov.chiSoNps!.diemNps.toString(), AppConfig.primaryColor),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Biểu đồ
                const Text("Thống kê xu hướng bình luận", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildBieuDoThongKe(prov),
                
                const SizedBox(height: 32),
                
                // Bảng quản lý sản phẩm
                const Text("Quản lý danh mục sản phẩm", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildBangDanhSachSanPham(prov),
              ],
            ),
          ),
    );
  }

  Widget _buildBieuDoThongKe(AppProvider prov) {
    return Container(
      height: 250, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppConfig.lightNavy, borderRadius: BorderRadius.circular(20)),
      child: BarChart(
        BarChartData(
          barGroups: prov.danhSachDiemThoiGian.asMap().entries.map((e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(toY: e.value.tichCuc.toDouble(), color: AppConfig.positiveColor, width: 10),
              BarChartRodData(toY: e.value.tieuCuc.toDouble(), color: AppConfig.negativeColor, width: 10),
            ],
          )).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(color: Colors.white54, fontSize: 10)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(v.toInt() >= 0 && v.toInt() < prov.danhSachDiemThoiGian.length ? prov.danhSachDiemThoiGian[v.toInt()].mox : '', style: const TextStyle(color: Colors.white54, fontSize: 10)))),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.white10, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildBangDanhSachSanPham(AppProvider prov) {
    return Container(
      decoration: BoxDecoration(color: AppConfig.lightNavy, borderRadius: BorderRadius.circular(20)),
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Sản phẩm', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Bình luận', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Trạng thái', style: TextStyle(color: Colors.white))),
        ],
        rows: prov.danhSachChuDe.map((topic) => DataRow(cells: [
          DataCell(Text(topic.tenChuDe, style: const TextStyle(color: AppConfig.primaryColor))),
          DataCell(Text(topic.soLuongBinhLuan.toString(), style: const TextStyle(color: Colors.white70))),
          DataCell(Chip(
            label: Text(topic.phanQuyetAi == 'APPROVED_NEN_MUA' ? 'NÊN MUA' : 'CÂN NHẮC', style: const TextStyle(fontSize: 10, color: Colors.white)),
            backgroundColor: topic.phanQuyetAi == 'APPROVED_NEN_MUA' ? AppConfig.positiveColor : AppConfig.negativeColor,
          )),
        ])).toList(),
      ),
    );
  }

  Widget _kpiCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppConfig.lightNavy, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 8), Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold))]),
    );
  }
}