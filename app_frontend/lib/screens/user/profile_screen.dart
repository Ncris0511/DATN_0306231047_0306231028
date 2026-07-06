import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_config.dart';
import '../../providers/app_provider.dart';
import '../gateway_screen.dart';
import 'user_login_screen.dart';
import 'user_register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _oldPwdController = TextEditingController();
  final _newPwdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _oldPwdController.dispose();
    _newPwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDarkMode;
    final hasUser = prov.isLoggedUser;

    // [ĐÃ NÂNG CẤP]: Xóa bỏ hoàn toàn biến ten_dang_nhap, chỉ dùng đúng email
    String hoTen = 'Người dùng';
    String email = 'Chưa cập nhật Email';
    String avatarChar = 'G';

    if (hasUser) {
      hoTen = prov.currentUser?['ho_ten']?.toString() ?? 'Người dùng';
      // Giờ chỉ đọc đúng trường 'email' từ Provider
      email = prov.currentUser?['email']?.toString() ?? 'Chưa cập nhật Email';
      avatarChar = hoTen.isNotEmpty ? hoTen[0].toUpperCase() : 'U';

      if (_nameController.text.isEmpty) {
        _nameController.text = hoTen;
      }
    }

    return Scaffold(
      backgroundColor: AppConfig.bg(isDark),
      appBar: AppBar(
        title: Text(
          'Cài đặt & Tài khoản',
          style: TextStyle(
            color: AppConfig.textMain(isDark),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppConfig.card(isDark),
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppConfig.textMain(isDark)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KHU VỰC AVATAR & THÔNG TIN CƠ BẢN
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppConfig.primary(
                      isDark,
                    ).withOpacity(0.15),
                    child: Text(
                      hasUser ? avatarChar : 'G',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.primary(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasUser ? hoTen : 'Khách vãng lai (Guest)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppConfig.textMain(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasUser
                          ? AppConfig.positiveColor.withOpacity(0.1)
                          : AppConfig.neutralColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasUser ? email : 'Chưa đồng bộ Cloud',
                      style: TextStyle(
                        color: hasUser
                            ? AppConfig.positiveColor
                            : AppConfig.neutralColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // NẾU LÀ KHÁCH ẨN DANH THÌ HIỆN NÚT ĐĂNG NHẬP / ĐĂNG KÝ
            if (!hasUser) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConfig.card(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConfig.border(isDark)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 40,
                      color: AppConfig.textSub(isDark),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nâng cấp Trải nghiệm',
                      style: TextStyle(
                        color: AppConfig.textMain(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đăng nhập để đồng bộ lịch sử hội chẩn AI lên đám mây và lưu trữ vĩnh viễn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppConfig.textSub(isDark),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primary(isDark),
                          foregroundColor: AppConfig.primaryText(isDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserLoginScreen(),
                          ),
                        ),
                        child: const Text(
                          'ĐĂNG NHẬP',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppConfig.border(isDark)),
                          foregroundColor: AppConfig.textMain(isDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserRegisterScreen(),
                          ),
                        ),
                        child: const Text(
                          'TẠO TÀI KHOẢN MIỄN PHÍ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // NẾU ĐÃ CÓ TÀI KHOẢN THÌ HIỆN FORM SỬA TÊN & ĐỔI MẬT KHẨU
            if (hasUser) ...[
              Text(
                'HỒ SƠ CÁ NHÂN',
                style: TextStyle(
                  color: AppConfig.textSub(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConfig.card(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConfig.border(isDark)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: AppConfig.textMain(isDark)),
                      decoration: InputDecoration(
                        labelText: 'Họ và Tên',
                        labelStyle: TextStyle(color: AppConfig.textSub(isDark)),
                        filled: true,
                        fillColor: AppConfig.inputBg(isDark),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primary(isDark),
                          foregroundColor: AppConfig.primaryText(isDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final success = await prov.capNhatHoTenUser(
                            _nameController.text.trim(),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Cập nhật tên thành công!'
                                      : 'Thất bại!',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'LƯU HỌ TÊN',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'BẢO MẬT TÀI KHOẢN',
                style: TextStyle(
                  color: AppConfig.textSub(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConfig.card(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConfig.border(isDark)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _oldPwdController,
                      obscureText: true,
                      style: TextStyle(color: AppConfig.textMain(isDark)),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu hiện tại',
                        labelStyle: TextStyle(color: AppConfig.textSub(isDark)),
                        filled: true,
                        fillColor: AppConfig.inputBg(isDark),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newPwdController,
                      obscureText: true,
                      style: TextStyle(color: AppConfig.textMain(isDark)),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        labelStyle: TextStyle(color: AppConfig.textSub(isDark)),
                        filled: true,
                        fillColor: AppConfig.inputBg(isDark),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.neutralColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_oldPwdController.text.isEmpty ||
                              _newPwdController.text.isEmpty)
                            return;
                          final success = await prov.doiMatKhauUser(
                            _oldPwdController.text,
                            _newPwdController.text,
                          );
                          if (success) {
                            _oldPwdController.clear();
                            _newPwdController.clear();
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Đổi mật khẩu thành công!'
                                      : 'Sai mật khẩu cũ!',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'ĐỔI MẬT KHẨU',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 48),
            // NÚT ĐĂNG XUẤT VÀ VỀ MÀN HÌNH CHÍNH
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.power_settings_new),
                label: const Text(
                  'VỀ MÀN HÌNH CHÍNH (GATEWAY)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppConfig.negativeColor),
                  foregroundColor: AppConfig.negativeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  if (hasUser) await prov.dangXuatClient();
                  if (context.mounted)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const GatewayScreen()),
                      (route) => false,
                    );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
