import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../services/app_controller.dart';
import 'medicine_form_page.dart';

/// Aba "Remédios": lista, cadastro, edição e exclusão.
class MedicinesPage extends StatelessWidget {
  const MedicinesPage({super.key, required this.controller});

  final AppController controller;

  Future<void> _openForm(BuildContext context, [Medicine? medicine]) async {
    final result = await Navigator.of(context).push<Medicine>(
      MaterialPageRoute(builder: (_) => MedicineFormPage(medicine: medicine)),
    );
    if (result != null) await controller.upsertMedicine(result);
  }

  Future<void> _confirmDelete(BuildContext context, Medicine med) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir remédio?'),
        content: Text(
          'Excluir "${med.name}" da lista?',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true) await controller.removeMedicine(med.id);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final meds = controller.medicines;
        return Scaffold(
          appBar: AppBar(title: const Text('Remédios')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add_rounded, size: 28),
            label: const Text('Adicionar', style: TextStyle(fontSize: 18)),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: meds.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Nenhum remédio cadastrado.\n'
                            'Toque em "Adicionar" para começar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        itemCount: meds.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final med = meds[i];
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                med.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  if (med.dose.isNotEmpty) med.dose,
                                  if (med.times.isNotEmpty)
                                    med.times.join(' · '),
                                  if (med.notes.isNotEmpty) med.notes,
                                ].join('\n'),
                                style: const TextStyle(fontSize: 18),
                              ),
                              isThreeLine: med.notes.isNotEmpty,
                              onTap: () => _openForm(context, med),
                              trailing: IconButton(
                                tooltip: 'Excluir',
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: () => _confirmDelete(context, med),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
