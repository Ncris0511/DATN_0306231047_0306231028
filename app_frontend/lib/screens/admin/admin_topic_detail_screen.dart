import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chu_de_model.dart';
import '../../models/sentiment_result.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_config.dart';

class AdminTopicDetailScreen extends StatefulWidget {
  final ChuDeModel topic;
  const AdminTopicDetailScreen({super.key, required this.topic});
  @override
  State<AdminTopicDetailScreen> createState() => _AdminTopicDetailScreenState();
}

class _AdminTopicDetailScreenState extends State<AdminTopicDetailScreen> {
  bool isLoading = true;
  List<KetQuaAI> history = [];
  int npsScore = 0;
  int tichCuc = 0;
  int tieuCuc = 0;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final api = ApiService();
    final data = await api.layChiTietPhienChat(widget.topic.id);
    if (data.isNotEmpty) {
      tichCuc = data.where((e) => e.nhanCamXuc == 'TICH_CUC').length;
      tieuCuc = data.where((e) => e.nhanCamXuc == 'TIEU_CUC').length;
      npsScore = (((tichCuc - tieuCuc) / data.length) * 100).round();
    }
    setState(() {
      history = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<AppProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppConfig.bg(isDark),
      appBar: AppBar(
        title: Text(
          "Giám sát: ${widget.topic.tenChuDe}",
          style: TextStyle(
            color: AppConfig.textMain(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppConfig.card(isDark),
        iconTheme: IconThemeData(color: AppConfig.textMain(isDark)),
        elevation: 1,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppConfig.primary(isDark),
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppConfig.card(isDark),
                    border: Border(
                      bottom: BorderSide(color: AppConfig.border(isDark)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "NPS Cục bộ",
                        style: TextStyle(
                          color: AppConfig.textSub(isDark),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$npsScore",
                        style: TextStyle(
                          color: npsScore > 0
                              ? AppConfig.positiveColor
                              : AppConfig.negativeColor,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _miniStat(
                            "Tích cực",
                            tichCuc.toString(),
                            AppConfig.positiveColor,
                            isDark,
                          ),
                          _miniStat(
                            "Tiêu cực",
                            tieuCuc.toString(),
                            AppConfig.negativeColor,
                            isDark,
                          ),
                          _miniStat(
                            "Tổng",
                            history.length.toString(),
                            AppConfig.primary(isDark),
                            isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppConfig.inputBg(isDark),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.psychology,
                                  color: AppConfig.primary(isDark),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Phán quyết AI:",
                                  style: TextStyle(
                                    color: AppConfig.textMain(isDark),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.topic.tomTatAi ?? 'Chưa hội chẩn',
                              style: TextStyle(
                                color: AppConfig.textMain(isDark),
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    separatorBuilder: (ctx, i) =>
                        Divider(height: 24, color: AppConfig.border(isDark)),
                    itemBuilder: (ctx, i) {
                      final kq = history[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppConfig.card(isDark),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppConfig.border(isDark)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '"${kq.noiDung}"',
                                    style: TextStyle(
                                      color: AppConfig.textMain(isDark),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (kq.nhanCamXuc != 'CHUA_PHAN_LOAI') ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppConfig.inputBg(isDark),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      kq.nhanCamXuc == 'TICH_CUC'
                                          ? Icons.thumb_up
                                          : Icons.thumb_down,
                                      color: kq.nhanCamXuc == 'TICH_CUC'
                                          ? AppConfig.positiveColor
                                          : AppConfig.negativeColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        kq.lyDoCuaAI,
                                        style: TextStyle(
                                          color: AppConfig.textSub(isDark),
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _miniStat(String label, String val, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppConfig.textSub(isDark), fontSize: 12),
        ),
      ],
    );
  }
}
