import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/theme.dart';

class AttachmentSection extends StatelessWidget {
  const AttachmentSection({
    super.key,
    required this.paths,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> paths;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  static Future<String?> pickAndSave(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final attachDir = Directory('${dir.path}/attachments');
    if (!attachDir.existsSync()) attachDir.createSync(recursive: true);

    final filename =
        'att_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final dest = File('${attachDir.path}/$filename');
    await dest.writeAsBytes(await picked.readAsBytes());
    return dest.path;
  }

  void _showSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppTheme.primaryColor),
              title: Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? 'الكاميرا'
                    : 'Camera',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final path =
                    await pickAndSave(ImageSource.camera);
                if (path != null) onAdd(path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppTheme.primaryColor),
              title: Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? 'معرض الصور'
                    : 'Gallery',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final path =
                    await pickAndSave(ImageSource.gallery);
                if (path != null) onAdd(path);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file_rounded,
                size: 16, color: Colors.white.withOpacity(0.6)),
            const SizedBox(width: 6),
            Text(
              isAr ? 'المرفقات (اختياري)' : 'Attachments (optional)',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Add button
              GestureDetector(
                onTap: () => _showSourcePicker(context),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(Icons.add_photo_alternate_rounded,
                      color: AppTheme.primaryColor.withOpacity(0.7), size: 28),
                ),
              ),
              const SizedBox(width: 8),
              // Thumbnails
              ...paths.map((p) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Thumbnail(
                      path: p,
                      onRemove: () => onRemove(p),
                      onTap: () => _openFullScreen(context, p),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  void _openFullScreen(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImage(path: path),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.path,
    required this.onRemove,
    required this.onTap,
  });

  final String path;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: file.existsSync()
                ? Image.file(file,
                    width: 72, height: 72, fit: BoxFit.cover)
                : Container(
                    width: 72,
                    height: 72,
                    color: AppTheme.surfaceDark,
                    child: Icon(Icons.broken_image_rounded,
                        color: Colors.white.withOpacity(0.3)),
                  ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  const _FullScreenImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(path)),
        ),
      ),
    );
  }
}
