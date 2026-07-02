import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  void _hienThiHopThoaiTaoChuDe(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConfig.lightNavy,
        title: const Text('Tạo chủ đề phân tích mới', 
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nhập tên sản phẩm/chủ đề...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppConfig.primaryColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AppProvider>().taoChuDeMoi(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Khởi tạo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return Drawer(
      child: Container(
        color: AppConfig.darkNavy,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppConfig.lightNavy),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppConfig.primaryColor.withOpacity(0.2),
                child: const Icon(Icons.person_outline, color: AppConfig.primaryColor, size: 32),
              ),
              accountName: Text(prov.guestUser?['ho_ten'] ?? 'Khách Ẩn Danh', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text('Mã Client: #${prov.guestUser?['id'] ?? '...'}', 
                  style: TextStyle(color: Colors.white.withOpacity(0.6))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _hienThiHopThoaiTaoChuDe(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('CHỦ ĐỀ MỚI', 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const Divider(color: Colors.white12),
            Expanded(
              child: ListView.builder(
                itemCount: prov.danhSachChuDe.length,
                itemBuilder: (context, idx) {
                  final topic = prov.danhSachChuDe[idx];
                  final isSelected = prov.chuDeHienTai?.id == topic.id;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppConfig.lightNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        topic.phanQuyetAi == 'APPROVED_NEN_MUA'
                            ? Icons.check_circle_outline
                            : topic.phanQuyetAi == 'CAUTION_CAN_NHAC'
                                ? Icons.warning_amber_rounded
                                : Icons.chat_bubble_outline_rounded,
                        color: topic.phanQuyetAi == 'APPROVED_NEN_MUA'
                            ? AppConfig.positiveColor
                            : topic.phanQuyetAi == 'CAUTION_CAN_NHAC'
                                ? AppConfig.neutralColor
                                : AppConfig.primaryColor,
                        size: 20,
                      ),
                      title: Text(
                        topic.tenChuDe,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      ),
                      subtitle: Text('${topic.soLuongBinhLuan} bình luận', 
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      onTap: () {
                        prov.chonPhienChuDe(topic);
                        Navigator.pop(context);
                      },
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