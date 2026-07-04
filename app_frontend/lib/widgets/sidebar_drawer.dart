import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';


class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Drawer(
      backgroundColor: AppConfig.darkNavy,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: AppConfig.primaryColor, child: Text(prov.isLoggedUser ? prov.currentUser!['ho_ten'][0].toUpperCase() : 'G', style: const TextStyle(fontWeight: FontWeight.bold, color: AppConfig.darkNavy))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prov.isLoggedUser ? prov.currentUser!['ho_ten'] : 'Khách Ẩn Danh', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(prov.isLoggedUser ? 'Gói Pro' : 'Dùng thử', style: TextStyle(color: AppConfig.primaryColor.withValues(alpha: 0.8), fontSize: 12)),
                    ],
                  )),
                ],
              ),
            ),
            
            // Thanh Tìm kiếm (Chức năng lọc)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (val) => context.read<AppProvider>().timKiemChuDe(val),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                  filled: true, fillColor: AppConfig.lightNavy,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),

            // Nút Tạo mới
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline, color: AppConfig.darkNavy), 
                label: const Text('Thêm Sản Phẩm Mới', style: TextStyle(color: AppConfig.darkNavy, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () { /* Hiện Dialog tạo chủ đề như cũ */ },
              ),
            ),
            const Divider(color: Colors.white10),

            // Danh sách phân nhóm như ChatGPT
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
              child: Text('LỊCH SỬ PHÂN TÍCH', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: prov.danhSachChuDe.length,
                itemBuilder: (context, index) {
                  final topic = prov.danhSachChuDe[index];
                  final isSelected = prov.chuDeHienTai?.id == topic.id;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(color: isSelected ? AppConfig.lightNavy : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.inventory_2_outlined, color: isSelected ? AppConfig.primaryColor : Colors.white38, size: 18),
                      title: Text(topic.tenChuDe, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                      onTap: () { prov.chonPhienChuDe(topic); Navigator.pop(context); },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}