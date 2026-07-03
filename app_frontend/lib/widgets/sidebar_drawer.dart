import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';
import '../screens/gateway_screen.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  void _hienThiHopThoaiTaoChuDe(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConfig.lightNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Chủ đề phân tích mới', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: 'Nhập tên sản phẩm/chủ đề...', hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, foregroundColor: AppConfig.darkNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AppProvider>().taoChuDeMoi(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tạo mới'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Drawer(
      backgroundColor: AppConfig.darkNavy,
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppConfig.lightNavy),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.2),
                child: Text(prov.isLoggedUser ? prov.currentUser!['ho_ten'].substring(0, 1).toUpperCase() : 'G', style: const TextStyle(color: AppConfig.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              accountName: Text(prov.isLoggedUser ? prov.currentUser!['ho_ten'] : 'Khách Ẩn Danh', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              accountEmail: Text(prov.isLoggedUser ? prov.currentUser!['email'] : 'Đăng nhập để lưu lịch sử', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: AppConfig.darkNavy), label: const Text('New Chat', style: TextStyle(color: AppConfig.darkNavy, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                onPressed: () => _hienThiHopThoaiTaoChuDe(context),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: prov.danhSachChuDe.length,
                itemBuilder: (context, index) {
                  final topic = prov.danhSachChuDe[index];
                  final isSelected = prov.chuDeHienTai?.id == topic.id;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isSelected ? AppConfig.lightNavy : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.chat_bubble_outline, color: isSelected ? AppConfig.primaryColor : Colors.white54, size: 20),
                      title: Text(topic.tenChuDe, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      onTap: () { prov.chonPhienChuDe(topic); Navigator.pop(context); },
                    ),
                  );
                },
              ),
            ),
            if (prov.isLoggedUser)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton.icon(
                  icon: const Icon(Icons.logout, color: AppConfig.negativeColor), label: const Text('Đăng xuất', style: TextStyle(color: AppConfig.negativeColor)),
                  onPressed: () { prov.dangXuatClient(); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const GatewayScreen()), (r) => false); },
                ),
              )
          ],
        ),
      ),
    );
  }
}