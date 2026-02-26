import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';
import 'package:intl/intl.dart';

class AdminBlogScreen extends ConsumerStatefulWidget {
  const AdminBlogScreen({super.key});

  @override
  ConsumerState<AdminBlogScreen> createState() => _AdminBlogScreenState();
}

class _AdminBlogScreenState extends ConsumerState<AdminBlogScreen> {
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final posts = await repo.getBlogPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.deleteBlogPost(id);
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _showPostForm({Map<String, dynamic>? post}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _BlogEditorPage(
          post: post,
          onSave: (data) async {
            final repo = ref.read(adminRepositoryProvider);
            if (post != null) {
              await repo.updateBlogPost(post['id'], data);
            } else {
              await repo.createBlogPost(data);
            }
            _load();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Blog')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostForm(),
        backgroundColor: AppColors.arena,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.arena))
          : RefreshIndicator(
              onRefresh: _load,
              child: _posts.isEmpty
                  ? const Center(child: Text('No hay artículos'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _posts.length,
                      itemBuilder: (ctx, i) {
                        final p = _posts[i] as Map<String, dynamic>;
                        final published = p['published'] == true;
                        final createdAt =
                            DateTime.tryParse(p['created_at'] ?? '');
                        final dateStr = createdAt != null
                            ? DateFormat('dd/MM/yyyy').format(createdAt)
                            : '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: p['image_url'] != null &&
                                    (p['image_url'] as String).isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      p['image_url'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 50,
                                        height: 50,
                                        color: AppColors.arenaPale,
                                        child: const Icon(Icons.article,
                                            color: AppColors.arena),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: AppColors.arenaPale,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.article,
                                        color: AppColors.arena),
                                  ),
                            title: Text(p['title'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Row(
                              children: [
                                Text(dateStr,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: published
                                        ? Colors.green.withValues(alpha: 0.15)
                                        : Colors.grey.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    published ? 'Publicado' : 'Borrador',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: published
                                            ? Colors.green
                                            : Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                    value: 'edit', child: Text('Editar')),
                                const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Eliminar',
                                        style: TextStyle(color: Colors.red))),
                              ],
                              onSelected: (v) {
                                if (v == 'edit') _showPostForm(post: p);
                                if (v == 'delete') _delete(p['id'].toString());
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

// ─── Full-screen Blog Editor with Rich Text Toolbar ─────────────────────────

class _BlogEditorPage extends StatefulWidget {
  final Map<String, dynamic>? post;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  const _BlogEditorPage({this.post, required this.onSave});

  @override
  State<_BlogEditorPage> createState() => _BlogEditorPageState();
}

class _BlogEditorPageState extends State<_BlogEditorPage> {
  late TextEditingController _titleC;
  late TextEditingController _slugC;
  late TextEditingController _excerptC;
  late TextEditingController _imageC;
  late TextEditingController _authorC;
  late TextEditingController _contentC;
  late bool _published;
  bool _saving = false;
  bool _showHtml = false;

  @override
  void initState() {
    super.initState();
    final p = widget.post;
    _titleC = TextEditingController(text: p?['title'] ?? '');
    _slugC = TextEditingController(text: p?['slug'] ?? '');
    _excerptC = TextEditingController(text: p?['excerpt'] ?? '');
    _imageC = TextEditingController(text: p?['image_url'] ?? '');
    _authorC = TextEditingController(text: p?['author'] ?? '');
    _contentC = TextEditingController(text: p?['content'] ?? '');
    _published = p?['published'] ?? false;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _slugC.dispose();
    _excerptC.dispose();
    _imageC.dispose();
    _authorC.dispose();
    _contentC.dispose();
    super.dispose();
  }

  void _insertTag(String openTag, String closeTag) {
    final text = _contentC.text;
    final sel = _contentC.selection;
    final start = sel.start;
    final end = sel.end;

    if (start < 0) {
      _contentC.text = '$text$openTag$closeTag';
      _contentC.selection =
          TextSelection.collapsed(offset: text.length + openTag.length);
    } else if (start == end) {
      final newText =
          text.substring(0, start) + openTag + closeTag + text.substring(end);
      _contentC.text = newText;
      _contentC.selection =
          TextSelection.collapsed(offset: start + openTag.length);
    } else {
      final selected = text.substring(start, end);
      final newText = text.substring(0, start) +
          openTag +
          selected +
          closeTag +
          text.substring(end);
      _contentC.text = newText;
      _contentC.selection = TextSelection(
        baseOffset: start + openTag.length,
        extentOffset: start + openTag.length + selected.length,
      );
    }
  }

  void _insertLink() {
    final urlCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Insertar enlace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Texto')),
            const SizedBox(height: 8),
            TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(labelText: 'URL')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final label =
                  labelCtrl.text.isEmpty ? urlCtrl.text : labelCtrl.text;
              final text = _contentC.text;
              final pos = _contentC.selection.start >= 0
                  ? _contentC.selection.start
                  : text.length;
              final tag = '<a href="${urlCtrl.text}">$label</a>';
              _contentC.text =
                  text.substring(0, pos) + tag + text.substring(pos);
              _contentC.selection =
                  TextSelection.collapsed(offset: pos + tag.length);
            },
            child: const Text('Insertar'),
          ),
        ],
      ),
    );
  }

  void _insertImage() {
    final urlCtrl = TextEditingController();
    final altCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Insertar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: urlCtrl,
                decoration:
                    const InputDecoration(labelText: 'URL de la imagen')),
            const SizedBox(height: 8),
            TextField(
                controller: altCtrl,
                decoration:
                    const InputDecoration(labelText: 'Texto alternativo')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final tag = '<img src="${urlCtrl.text}" alt="${altCtrl.text}" />';
              final text = _contentC.text;
              final pos = _contentC.selection.start >= 0
                  ? _contentC.selection.start
                  : text.length;
              _contentC.text =
                  text.substring(0, pos) + tag + text.substring(pos);
              _contentC.selection =
                  TextSelection.collapsed(offset: pos + tag.length);
            },
            child: const Text('Insertar'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_titleC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El título es obligatorio')));
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave({
        'title': _titleC.text,
        'slug': _slugC.text.isNotEmpty
            ? _slugC.text
            : _titleC.text
                .toLowerCase()
                .replaceAll(' ', '-')
                .replaceAll(RegExp(r'[^a-z0-9\-]'), ''),
        'excerpt': _excerptC.text,
        'content': _contentC.text,
        'image_url': _imageC.text,
        'author': _authorC.text,
        'published': _published,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post != null ? 'Editar Artículo' : 'Nuevo Artículo'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
                onPressed: _save,
                child: const Text('Guardar',
                    style: TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: _titleC,
              decoration: const InputDecoration(
                  labelText: 'Título', border: OutlineInputBorder()),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: TextField(
                    controller: _slugC,
                    decoration: const InputDecoration(
                        labelText: 'Slug', border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(
                child: TextField(
                    controller: _authorC,
                    decoration: const InputDecoration(
                        labelText: 'Autor', border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),
          TextField(
              controller: _excerptC,
              decoration: const InputDecoration(
                  labelText: 'Extracto', border: OutlineInputBorder()),
              maxLines: 2),
          const SizedBox(height: 12),
          TextField(
              controller: _imageC,
              decoration: const InputDecoration(
                  labelText: 'URL imagen', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          SwitchListTile(
              title: const Text('Publicado'),
              value: _published,
              activeColor: AppColors.arena,
              onChanged: (v) => setState(() => _published = v),
              contentPadding: EdgeInsets.zero),
          const SizedBox(height: 8),

          // Content header + HTML toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Contenido',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: () => setState(() => _showHtml = !_showHtml),
                icon: Icon(_showHtml ? Icons.visibility : Icons.code, size: 18),
                label: Text(_showHtml ? 'Editor' : 'HTML'),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Toolbar
          if (!_showHtml)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.arenaPale,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                border: Border.all(color: AppColors.arenaLight),
              ),
              child: Wrap(
                spacing: 2,
                children: [
                  _ToolBtn(
                      icon: Icons.format_bold,
                      tooltip: 'Negrita',
                      onPressed: () => _insertTag('<strong>', '</strong>')),
                  _ToolBtn(
                      icon: Icons.format_italic,
                      tooltip: 'Cursiva',
                      onPressed: () => _insertTag('<em>', '</em>')),
                  _ToolBtn(
                      icon: Icons.format_underlined,
                      tooltip: 'Subrayado',
                      onPressed: () => _insertTag('<u>', '</u>')),
                  const SizedBox(
                      width: 8, height: 24, child: VerticalDivider()),
                  _ToolBtn(
                      icon: Icons.title,
                      tooltip: 'Título H2',
                      onPressed: () => _insertTag('<h2>', '</h2>')),
                  _ToolBtn(
                      icon: Icons.text_fields,
                      tooltip: 'Subtítulo H3',
                      onPressed: () => _insertTag('<h3>', '</h3>')),
                  const SizedBox(
                      width: 8, height: 24, child: VerticalDivider()),
                  _ToolBtn(
                      icon: Icons.format_list_bulleted,
                      tooltip: 'Lista',
                      onPressed: () =>
                          _insertTag('<ul>\n  <li>', '</li>\n</ul>')),
                  _ToolBtn(
                      icon: Icons.format_list_numbered,
                      tooltip: 'Lista num.',
                      onPressed: () =>
                          _insertTag('<ol>\n  <li>', '</li>\n</ol>')),
                  const SizedBox(
                      width: 8, height: 24, child: VerticalDivider()),
                  _ToolBtn(
                      icon: Icons.link,
                      tooltip: 'Enlace',
                      onPressed: _insertLink),
                  _ToolBtn(
                      icon: Icons.image,
                      tooltip: 'Imagen',
                      onPressed: _insertImage),
                  _ToolBtn(
                      icon: Icons.format_quote,
                      tooltip: 'Cita',
                      onPressed: () =>
                          _insertTag('<blockquote>', '</blockquote>')),
                ],
              ),
            ),

          // Content text area
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.arenaLight),
              borderRadius: _showHtml
                  ? BorderRadius.circular(8)
                  : const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: TextField(
              controller: _contentC,
              maxLines: 15,
              decoration: InputDecoration(
                hintText: _showHtml
                    ? 'HTML aquí...'
                    : 'Escribe el contenido del artículo...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: _showHtml ? 'monospace' : null,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolBtn(
      {required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
