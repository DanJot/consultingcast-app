import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/company.dart';

class DocumentManagementPage extends StatefulWidget {
  final Company company;
  const DocumentManagementPage({super.key, required this.company});

  @override
  State<DocumentManagementPage> createState() => _DocumentManagementPageState();
}

class _DocumentManagementPageState extends State<DocumentManagementPage> {
  final List<File> _docs = [];
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão Documental'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroCard(context),
            const SizedBox(height: 16),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _heroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_copy_outlined, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Documentos da Empresa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Empresa: ${widget.company.name}', style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (_docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.drive_folder_upload_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Sem documentos. Use o botão + para adicionar.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1),
      itemCount: _docs.length,
      itemBuilder: (context, index) {
        final f = _docs[index];
        final ext = p.extension(f.path).toLowerCase();
        final isImage = ['.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp'].contains(ext);
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onLongPress: () => setState(() => _docs.removeAt(index)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isImage
                          ? Image.file(f, fit: BoxFit.cover, width: double.infinity)
                          : Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Icon(Icons.description_outlined, color: Colors.grey.shade600, size: 42),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.basename(f.path),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFab() {
    return ExpandableFab(
      onPickFile: _pickFile,
      onTakePhoto: _takePhoto,
      onSaveAll: _simulateSave,
    );
  }

  Future<void> _pickFile() async {
    if (!await _ensureStoragePermission()) return;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any, // abre o seletor de ficheiros do sistema, não apenas fotos
    );
    if (result == null) return;
    final files = result.paths.whereType<String>().map((e) => File(e));
    setState(() => _docs.addAll(files));
  }

  Future<void> _takePhoto() async {
    if (!await _ensureCameraPermission()) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (x == null) return;
    // Move para diretório temporário da app
    final dir = await getTemporaryDirectory();
    final target = File(p.join(dir.path, p.basename(x.path)));
    await File(x.path).copy(target.path);
    setState(() => _docs.add(target));
  }

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<bool> _ensureStoragePermission() async {
    // Android 13+: READ_MEDIA_IMAGES, abaixo: READ_EXTERNAL_STORAGE
    final photos = await Permission.photos.request();
    if (photos.isGranted) return true;
    final storage = await Permission.storage.request();
    if (storage.isGranted) return true;
    if (photos.isPermanentlyDenied || storage.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<void> _simulateSave() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Documentos guardados (simulação)')),
    );
  }
}

class ExpandableFab extends StatefulWidget {
  final VoidCallback onPickFile;
  final VoidCallback onTakePhoto;
  final VoidCallback onSaveAll;
  const ExpandableFab({super.key, required this.onPickFile, required this.onTakePhoto, required this.onSaveAll});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double panelWidth = _open ? 220 : 56;
    final double panelHeight = _open ? 220 : 56;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: panelWidth,
      height: panelHeight,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_open) ...[
              _PillButton(icon: Icons.add_photo_alternate_outlined, label: 'Ficheiro', onTap: _tap(widget.onPickFile)),
              const SizedBox(height: 8),
              _PillButton(icon: Icons.photo_camera_outlined, label: 'Câmara', onTap: _tap(widget.onTakePhoto)),
              const SizedBox(height: 8),
              _PillButton(icon: Icons.cloud_upload_outlined, label: 'Guardar', onTap: _tap(widget.onSaveAll)),
              const SizedBox(height: 10),
            ],
            FloatingActionButton(
              backgroundColor: const Color(0xFF0EA5E9),
              foregroundColor: Colors.white,
              onPressed: () {
                setState(() { _open = !_open; });
                if (_open) { _ctrl.forward(); } else { _ctrl.reverse(); }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Icon(_open ? Icons.close : Icons.add, key: ValueKey(_open)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback _tap(VoidCallback cb) {
    return () { setState(() { _open = false; }); cb(); };
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0EA5E9),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}


