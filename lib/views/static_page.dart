import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';

class StaticPage extends StatefulWidget {
  final String slug;
  final String title;
  const StaticPage({super.key, required this.slug, required this.title});

  @override
  State<StaticPage> createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {
  String? _content;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService().getStaticPage(context, widget.slug);
      setState(() {
        _content = (data['content'] ?? '').toString().replaceAll(RegExp(r'<[^>]*>'), '');
        _loading = false;
      });
    } catch (_) {
      setState(() { _content = 'Failed to load content.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(_content ?? '', style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87)),
            ),
    );
  }
}
