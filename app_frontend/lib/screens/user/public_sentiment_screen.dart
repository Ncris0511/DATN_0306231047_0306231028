import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/app_config.dart';
import '../../providers/app_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/sidebar_drawer.dart';

class PublicSentimentScreen extends StatefulWidget {
  const PublicSentimentScreen({super.key});
  @override
  State<PublicSentimentScreen> createState() => _PublicSentimentScreenState();
}

class _PublicSentimentScreenState extends State<PublicSentimentScreen> {
  final TextEditingController _noiDungController = TextEditingController();
  File? _selectedFile;
  bool _isImageFile = true;
  final ScrollController _scrollController = ScrollController();

  Future<void> _pickImage() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null)
      setState(() {
        _selectedFile = File(pickedFile.path);
        _isImageFile = true;
      });
  }

  Future<void> _pickDocument() async {
    Navigator.pop(context);
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    if (result != null)
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _isImageFile = false;
      });
  }

  Future<void> _pickCamera() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (pickedFile != null)
      setState(() {
        _selectedFile = File(pickedFile.path);
        _isImageFile = true;
      });
  }

  void _guiTinNhanPhanTich() {
    final text = _noiDungController.text.trim();
    if (text.isEmpty && _selectedFile == null) return;
    context.read<AppProvider>().guiBinhLuanVaPhanTich(
      text,
      fileDinhKem: _selectedFile,
      isImage: _isImageFile,
    );
    _noiDungController.clear();
    setState(() => _selectedFile = null);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients)
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    });
  }

  void _hienThiMenuDinhKem(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppConfig.card(isDark),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChucNangDinhKem(
                  Icons.image,
                  Colors.blue,
                  "Hình ảnh",
                  _pickImage,
                  isDark,
                ),
                _buildChucNangDinhKem(
                  Icons.description,
                  Colors.orange,
                  "Tài liệu",
                  _pickDocument,
                  isDark,
                ),
                _buildChucNangDinhKem(
                  Icons.camera_alt,
                  Colors.green,
                  "Máy ảnh",
                  _pickCamera,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildChucNangDinhKem(
    IconData icon,
    Color color,
    String label,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppConfig.textMain(isDark),
              fontSize: 13,
              fontWeight: FontWeight.bold,
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

  void _hienThiBangHoiChan(bool isDark) async {
    final prov = context.read<AppProvider>();
    if (prov.chuDeHienTai == null) return;

    // NẾU CHƯA HỘI CHẨN -> HIỆU ỨNG SÓNG ÂM (RADAR PULSE) ĐẸP MẮT
    if (prov.chuDeHienTai!.phanQuyetAi == 'CHUA_HOI_CHAN') {
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.7),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (ctx, anim1, anim2) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: AppConfig.card(isDark),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppConfig.primary(isDark).withOpacity(0.4),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RippleLoading(
                      color: AppConfig.primary(isDark),
                    ), // Gọi hiệu ứng nhịp đập ở dưới
                    const SizedBox(height: 32),
                    Text(
                      "AI Đang Phân Tích...",
                      style: TextStyle(
                        color: AppConfig.textMain(isDark),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Đang tổng hợp dữ liệu từ các bình luận. Vui lòng giữ màn hình.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppConfig.textSub(isDark),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // ĐÃ VÁ LỖI INFINITE LOOP: Bắt buộc lấy biến success
      final success = await prov.goiHoiChanChotHa();
      if (mounted) Navigator.pop(context); // Tắt loading

      if (success && mounted) {
        _hienThiBangHoiChan(isDark); // Mở bảng nếu thành công
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Chưa có đủ bình luận để AI hội chẩn!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppConfig.negativeColor,
          ),
        );
      }
      return;
    }

    // GIAO DIỆN BÁO CÁO PHÁN QUYẾT RÕ RÀNG
    final isNenMua = prov.chuDeHienTai!.phanQuyetAi == 'APPROVED_NEN_MUA';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppConfig.card(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isNenMua
                    ? AppConfig.positiveColor.withOpacity(0.1)
                    : AppConfig.negativeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNenMua ? Icons.verified_rounded : Icons.gavel_rounded,
                color: isNenMua
                    ? AppConfig.positiveColor
                    : AppConfig.negativeColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "BÁO CÁO TỔNG HỢP SENTIFLOW",
              style: TextStyle(
                color: AppConfig.textSub(isDark),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isNenMua ? "SẢN PHẨM ĐÁNG MUA" : "CẢNH BÁO RỦI RO CAO",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isNenMua
                    ? AppConfig.positiveColor
                    : AppConfig.negativeColor,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConfig.inputBg(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppConfig.border(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppConfig.primary(isDark),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Lời khuyên từ AI:",
                        style: TextStyle(
                          color: AppConfig.textMain(isDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    prov.chuDeHienTai!.tomTatAi ?? 'Không có dữ liệu',
                    style: TextStyle(
                      color: AppConfig.textSub(isDark),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primary(isDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  "ĐÓNG BÁO CÁO",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppConfig.primaryText(isDark),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ĐẠI TU EMPTY STATE (MÀN HÌNH CHỜ) HIỆN ĐẠI BẮT MẮT
  Widget _buildEmptyState(AppProvider prov, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConfig.primary(isDark).withOpacity(0.05),
                border: Border.all(
                  color: AppConfig.primary(isDark).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 80,
                color: AppConfig.primary(isDark),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Không gian Phân tích",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppConfig.textMain(isDark),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Vui lòng chọn một phiên có sẵn hoặc tạo phiên mới để bắt đầu nạp dữ liệu cho SentiFlow AI.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppConfig.textSub(isDark),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add, color: AppConfig.primaryText(isDark)),
                label: Text(
                  "TẠO SẢN PHẨM MỚI",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppConfig.primaryText(isDark),
                    letterSpacing: 1.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primary(isDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppConfig.primary(isDark).withOpacity(0.3),
                ),
                onPressed: () => _hienThiDialogTaoChuDe(context, prov, isDark),
              ),
            ),
            const SizedBox(height: 40),

            if (prov.danhSachChuDe.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "PHIÊN LÀM VIỆC GẦN ĐÂY",
                  style: TextStyle(
                    color: AppConfig.textSub(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppConfig.card(isDark),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppConfig.border(isDark)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: prov.danhSachChuDe.length > 5
                      ? 5
                      : prov.danhSachChuDe.length,
                  separatorBuilder: (ctx, i) =>
                      Divider(height: 1, color: AppConfig.border(isDark)),
                  itemBuilder: (ctx, i) {
                    final item = prov.danhSachChuDe[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppConfig.inputBg(isDark),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          color: AppConfig.primary(isDark),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        item.tenChuDe,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConfig.textMain(isDark),
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${item.soLuongBinhLuan} bình luận',
                          style: TextStyle(
                            color: AppConfig.textSub(isDark),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: AppConfig.textSub(isDark),
                      ),
                      onTap: () => prov.chonPhienChuDe(item),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAILoading(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppConfig.primary(isDark).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppConfig.primary(isDark),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConfig.card(isDark),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: AppConfig.border(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppConfig.primary(isDark),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Shimmer.fromColors(
                        baseColor: AppConfig.primary(isDark),
                        highlightColor: Colors.purpleAccent,
                        child: const Text(
                          "SentiFlow đang đọc dữ liệu...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Shimmer.fromColors(
                    baseColor: AppConfig.border(isDark),
                    highlightColor: AppConfig.inputBg(isDark),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDarkMode;

    List<Widget> chatWidgets = [];
    if (prov.chuDeHienTai != null) {
      for (var kq in prov.cuocHoiThoaiHienTai) {
        chatWidgets.add(
          ChatBubble(text: kq.noiDung, isUser: true, sentiment: ''),
        );
        if (kq.nhanCamXuc != 'CHUA_PHAN_LOAI' || kq.lyDoCuaAI.isNotEmpty) {
          chatWidgets.add(
            ChatBubble(
              text: "",
              isUser: false,
              sentiment: kq.nhanCamXuc,
              ketQuaAI: kq,
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: AppConfig.bg(isDark),
      appBar: AppBar(
        title: Text(
          prov.chuDeHienTai?.tenChuDe ?? "SentiFlow AI",
          style: TextStyle(
            color: AppConfig.textMain(isDark),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppConfig.card(isDark),
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppConfig.textMain(isDark)),
        actions: [
          if (prov.chuDeHienTai != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton.icon(
                icon: Icon(
                  Icons.gavel_rounded,
                  color: prov.chuDeHienTai!.phanQuyetAi == 'CHUA_HOI_CHAN'
                      ? AppConfig.textSub(isDark)
                      : AppConfig.primary(isDark),
                ),
                label: Text(
                  prov.chuDeHienTai!.phanQuyetAi == 'CHUA_HOI_CHAN'
                      ? "Hội chẩn"
                      : "Xem Phán Quyết",
                  style: TextStyle(
                    color: prov.chuDeHienTai!.phanQuyetAi == 'CHUA_HOI_CHAN'
                        ? AppConfig.textSub(isDark)
                        : AppConfig.primary(isDark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _hienThiBangHoiChan(isDark),
              ),
            ),
        ],
      ),
      drawer: const SidebarDrawer(),
      body: prov.chuDeHienTai == null
          ? _buildEmptyState(prov, isDark)
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 16, bottom: 20),
                    children: [
                      ...chatWidgets,
                      if (prov.isAnalyzing) _buildAILoading(isDark),
                    ],
                  ),
                ),
                if (_selectedFile != null)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppConfig.card(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppConfig.border(isDark)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isImageFile
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  _selectedFile!,
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedFile!.path.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppConfig.textMain(isDark),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: AppConfig.negativeColor,
                          ),
                          onPressed: () => setState(() => _selectedFile = null),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppConfig.card(isDark),
                    border: Border(
                      top: BorderSide(color: AppConfig.border(isDark)),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: AppConfig.primary(isDark),
                            size: 28,
                          ),
                          onPressed: () => _hienThiMenuDinhKem(isDark),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppConfig.inputBg(isDark),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _noiDungController,
                              style: TextStyle(
                                color: AppConfig.textMain(isDark),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Hỏi AI về sản phẩm...',
                                hintStyle: TextStyle(
                                  color: AppConfig.textSub(isDark),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _guiTinNhanPhanTich(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: AppConfig.primary(isDark),
                          radius: 22,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_upward_rounded,
                              color: AppConfig.primaryText(isDark),
                              size: 20,
                            ),
                            onPressed: _guiTinNhanPhanTich,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// HIỆU ỨNG SÓNG ÂM (RADAR PULSE) DÙNG TRONG LÚC LOADING HỘI CHẨN
class RippleLoading extends StatefulWidget {
  final Color color;
  const RippleLoading({super.key, required this.color});
  @override
  State<RippleLoading> createState() => _RippleLoadingState();
}

class _RippleLoadingState extends State<RippleLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80 + (_controller.value * 50),
              height: 80 + (_controller.value * 50),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(1.0 - _controller.value),
              ),
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                color: widget.color,
                strokeWidth: 4,
              ),
            ),
            Icon(Icons.psychology, size: 40, color: widget.color),
          ],
        );
      },
    );
  }
}
