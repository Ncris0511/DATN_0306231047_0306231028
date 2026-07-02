import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// Đảm bảo đường dẫn import đúng cấu trúc thư mục của bạn
import '../utils/app_config.dart';
import '../providers/app_provider.dart';
import '../widgets/sidebar_drawer.dart'; 

class PublicSentimentScreen extends StatefulWidget {
  const PublicSentimentScreen({super.key});

  @override
  State<PublicSentimentScreen> createState() => _PublicSentimentScreenState();
}

class _PublicSentimentScreenState extends State<PublicSentimentScreen> {
  final TextEditingController _noiDungController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _guiTinNhanPhanTich() {
    final text = _noiDungController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    context.read<AppProvider>().guiBinhLuanVaPhanTich(text, imageFile: _selectedImage);
    _noiDungController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  void dispose() {
    _noiDungController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final currentTopic = prov.chuDeHienTai;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppConfig.darkNavy,
        title: Text(
          currentTopic?.tenChuDe ?? 'Đang tải phiên...',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (prov.cuocHoiThoaiHienTai.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.gavel_rounded, color: AppConfig.primaryColor),
              onPressed: () => prov.kichHoatHoiChanPhien(),
            )
        ],
      ),
      drawer: const SidebarDrawer(),
      body: Column(
        children: [
          Expanded(
            child: prov.cuocHoiThoaiHienTai.isEmpty
                ? const Center(child: Text('Hãy bắt đầu phân tích...'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: prov.cuocHoiThoaiHienTai.length,
                    itemBuilder: (context, index) {
                      final chat = prov.cuocHoiThoaiHienTai[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(chat.noiDung, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Kết quả: ${chat.nhanCamXuc}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_selectedImage != null)
            Container(padding: const EdgeInsets.all(8), color: Colors.grey.shade200, child: Row(children: [Text("Ảnh đã chọn"), IconButton(icon: const Icon(Icons.cancel), onPressed: () => setState(() => _selectedImage = null))])),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.image), onPressed: _pickImage),
                Expanded(child: TextField(controller: _noiDungController, decoration: const InputDecoration(hintText: 'Nhập bình luận...'))),
                IconButton(icon: const Icon(Icons.send), onPressed: _guiTinNhanPhanTich),
              ],
            ),
          )
        ],
      ),
    );
  }
}