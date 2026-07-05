import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';
import '../screens/gateway_screen.dart';
import '../screens/user/profile_screen.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  Future<bool?> _hienThiXacNhanXoa(BuildContext context, bool isDark) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConfig.card(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppConfig.negativeColor,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Xác nhận Xóa',
              style: TextStyle(
                color: AppConfig.textMain(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa vĩnh viễn sản phẩm này cùng toàn bộ lịch sử hội chẩn AI?',
          style: TextStyle(
            color: AppConfig.textSub(isDark),
            height: 1.5,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'HỦY',
              style: TextStyle(color: AppConfig.textSub(isDark)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.negativeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'XÓA NGAY',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _hienThiDialogTaoChuDe(
    BuildContext context,
    AppProvider prov,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        final txtCtrl = TextEditingController();
        return AlertDialog(
          backgroundColor: AppConfig.card(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.add_circle,
                color: AppConfig.primary(isDark),
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Tạo Sản Phẩm Mới',
                style: TextStyle(
                  color: AppConfig.textMain(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: txtCtrl,
            style: TextStyle(color: AppConfig.textMain(isDark)),
            decoration: InputDecoration(
              hintText: 'VD: Nước hoa Dior, Giày Nike...',
              hintStyle: TextStyle(color: AppConfig.textSub(isDark)),
              filled: true,
              fillColor: AppConfig.inputBg(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'HỦY',
                style: TextStyle(color: AppConfig.textSub(isDark)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primary(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                prov.taoChuDeMoi(txtCtrl.text);
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text(
                'BẮT ĐẦU',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConfig.primaryText(isDark),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDarkMode;

    // [ĐÃ BỌC THÉP CHỐNG NULL]: Tự động gán giá trị nếu Backend thiếu dữ liệu
    String hoTen = 'Khách Ẩn Danh';
    if (prov.isLoggedUser) {
      hoTen = prov.currentUser?['ho_ten']?.toString() ?? 'Người dùng';
    }
    String avatarChar = (prov.isLoggedUser && hoTen.isNotEmpty)
        ? hoTen[0].toUpperCase()
        : 'G';

    return Drawer(
      backgroundColor: AppConfig.bg(isDark),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppConfig.primary(isDark),
                      child: Text(
                        avatarChar,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConfig.primaryText(isDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hoTen,
                            style: TextStyle(
                              color: AppConfig.textMain(isDark),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            prov.isLoggedUser
                                ? 'Xem Hồ Sơ / Quản lý'
                                : 'Bấm vào để Đăng nhập',
                            style: TextStyle(
                              color: AppConfig.primary(isDark),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: AppConfig.primary(isDark),
              ),
              title: Text(
                isDark ? 'Chế độ Tối' : 'Chế độ Sáng',
                style: TextStyle(
                  color: AppConfig.textMain(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Switch(
                value: isDark,
                activeColor: AppConfig.primary(isDark),
                onChanged: (val) => prov.toggleTheme(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                style: TextStyle(
                  color: AppConfig.textMain(isDark),
                  fontSize: 14,
                ),
                onChanged: (val) => prov.timKiemChuDe(val),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: TextStyle(color: AppConfig.textSub(isDark)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppConfig.textSub(isDark),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppConfig.inputBg(isDark),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Divider(color: AppConfig.border(isDark)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LỊCH SỬ PHÂN TÍCH',
                    style: TextStyle(
                      color: AppConfig.textSub(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  InkWell(
                    onTap: () => _hienThiDialogTaoChuDe(context, prov, isDark),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppConfig.primary(isDark).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: AppConfig.primary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: prov.danhSachChuDe.length,
                itemBuilder: (context, index) {
                  final topic = prov.danhSachChuDe[index];
                  final isSelected = prov.chuDeHienTai?.id == topic.id;

                  return Dismissible(
                    key: Key(topic.id.toString()),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) =>
                        _hienThiXacNhanXoa(context, isDark),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: AppConfig.negativeColor,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) => prov.xoaChuDeX(topic.id),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppConfig.card(isDark)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.inventory_2_outlined,
                          color: isSelected
                              ? AppConfig.primary(isDark)
                              : AppConfig.textSub(isDark),
                          size: 18,
                        ),
                        title: Text(
                          topic.tenChuDe,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? AppConfig.textMain(isDark)
                                : AppConfig.textSub(isDark),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        trailing: CircleAvatar(
                          radius: 10,
                          backgroundColor: AppConfig.inputBg(isDark),
                          child: Text(
                            topic.soLuongBinhLuan.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppConfig.textMain(isDark),
                            ),
                          ),
                        ),
                        onTap: () {
                          prov.chonPhienChuDe(topic);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(color: AppConfig.border(isDark)),
            if (prov.isLoggedUser)
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: AppConfig.negativeColor,
                ),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: AppConfig.negativeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  await prov.dangXuatClient();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const GatewayScreen()),
                    (r) => false,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
