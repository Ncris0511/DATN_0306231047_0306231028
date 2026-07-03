import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_config.dart';
import '../providers/app_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/sidebar_drawer.dart';

class PublicSentimentScreen extends StatefulWidget {
  const PublicSentimentScreen({super.key});
  @override
  State<PublicSentimentScreen> createState() => _PublicSentimentScreenState();
}

class _PublicSentimentScreenState extends State<PublicSentimentScreen> {
  final TextEditingController _noiDungController = TextEditingController();
  File? _selectedImage;
  final ScrollController _scrollController = ScrollController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  void _guiTinNhanPhanTich() {
    final text = _noiDungController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;
    context.read<AppProvider>().guiBinhLuanVaPhanTich(text, imageFile: _selectedImage);
    _noiDungController.clear(); setState(() => _selectedImage = null);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppConfig.darkNavy,
      appBar: AppBar(
        title: Text(prov.chuDeHienTai?.tenChuDe ?? "SentiFlow AI", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppConfig.darkNavy, elevation: 0, iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const SidebarDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: prov.cuocHoiThoaiHienTai.length,
              itemBuilder: (context, i) => ChatBubble(
                text: prov.cuocHoiThoaiHienTai[i].noiDung,
                isUser: false, 
                sentiment: prov.cuocHoiThoaiHienTai[i].nhanCamXuc,
              ),
            ),
          ),
          if (prov.isAnalyzing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppConfig.primaryColor, strokeWidth: 2)),
                  const SizedBox(width: 12),
                  Text("AI đang phân tích...", style: TextStyle(color: AppConfig.primaryColor.withValues(alpha: 0.8), fontSize: 13, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppConfig.lightNavy, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_selectedImage!, width: 50, height: 50, fit: BoxFit.cover)),
                  const SizedBox(width: 12),
                  const Expanded(child: Text("Đã đính kèm ảnh", style: TextStyle(color: Colors.white70))),
                  IconButton(icon: const Icon(Icons.cancel, color: Colors.white54), onPressed: () => setState(() => _selectedImage = null)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(color: AppConfig.darkNavy, border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1)))),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.image_outlined, color: Colors.white54), onPressed: _pickImage),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: AppConfig.lightNavy, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                      child: TextField(
                        controller: _noiDungController, style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(hintText: 'Nhắn tin cho AI...', hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)), border: InputBorder.none),
                        onSubmitted: (_) => _guiTinNhanPhanTich(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(backgroundColor: AppConfig.primaryColor, radius: 22, child: IconButton(icon: const Icon(Icons.send_rounded, color: AppConfig.darkNavy, size: 20), onPressed: _guiTinNhanPhanTich)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}