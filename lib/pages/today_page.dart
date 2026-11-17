import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../services/app_controller.dart';
import '../services/image_export.dart';
import '../utils/date_format_pt.dart';
import '../widgets/agenda_card.dart';

/// Aba "Hoje": agenda do dia com marcação de doses tomadas e botão de
/// compartilhar a agenda como imagem.
class TodayPage extends StatefulWidget {
  const TodayPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sharing = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data!.buffer.asUint8List();

      final now = DateTime.now();
      final name = widget.controller.elderName;
      final result = await sharePng(
        bytes,
        filename: 'remedios-${AppController.dayKey(now)}.png',
        title: 'Remédios do dia',
        text: 'Remédios de ${name.isEmpty ? 'hoje' : name} — '
            '${formatLongDatePt(now)}',
      );

      if (!mounted) return;
      if (result == ExportResult.downloaded) {
        messenger.showSnackBar(const SnackBar(
          content: Text('Imagem salva no aparelho. Envie pelo WhatsApp.'),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Não foi possível gerar a imagem: $e')),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final today = DateTime.now();

    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Hoje'),
            actions: [
              IconButton(
                tooltip: 'Nome do idoso',
                icon: const Icon(Icons.person_rounded),
                onPressed: () => _editName(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: AgendaCard(
                          date: today,
                          elderName: c.elderName,
                          doses: c.dosesFor(today),
                          onToggle: (dose) => c.toggleTaken(today, dose),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toque em um remédio para marcar como tomado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 64,
                      child: FilledButton.icon(
                        onPressed: _sharing ? null : _share,
                        icon: _sharing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              )
                            : const Icon(Icons.share_rounded, size: 28),
                        label: const Text(
                          'Compartilhar imagem',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editName(BuildContext context) async {
    final controller = TextEditingController(text: widget.controller.elderName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nome do idoso'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(fontSize: 20),
          decoration: const InputDecoration(hintText: 'Ex.: Dona Maria'),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (name != null) await widget.controller.setElderName(name);
  }
}
