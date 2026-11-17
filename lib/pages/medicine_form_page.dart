import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../utils/date_format_pt.dart';

/// Formulário de cadastro/edição de remédio. Devolve o [Medicine] ao salvar.
class MedicineFormPage extends StatefulWidget {
  const MedicineFormPage({super.key, this.medicine});

  final Medicine? medicine;

  @override
  State<MedicineFormPage> createState() => _MedicineFormPageState();
}

class _MedicineFormPageState extends State<MedicineFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _dose;
  late final TextEditingController _notes;
  late List<String> _times;
  String? _timesError;

  @override
  void initState() {
    super.initState();
    final m = widget.medicine;
    _name = TextEditingController(text: m?.name ?? '');
    _dose = TextEditingController(text: m?.dose ?? '');
    _notes = TextEditingController(text: m?.notes ?? '');
    _times = List<String>.of(m?.times ?? const []);
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    final hm = formatHm(picked.hour, picked.minute);
    if (_times.contains(hm)) return;
    setState(() {
      _times = [..._times, hm]..sort();
      _timesError = null;
    });
  }

  void _save() {
    final valid = _formKey.currentState!.validate();
    if (_times.isEmpty) {
      setState(() => _timesError = 'Adicione pelo menos um horário.');
      return;
    }
    if (!valid) return;

    final id = widget.medicine?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();
    Navigator.of(context).pop(Medicine(
      id: id,
      name: _name.text.trim(),
      dose: _dose.text.trim(),
      notes: _notes.text.trim(),
      times: _times,
    ));
  }

  @override
  Widget build(BuildContext context) {
    const fieldStyle = TextStyle(fontSize: 20);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Novo remédio' : 'Editar remédio'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _name,
                    style: fieldStyle,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nome do remédio',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o nome do remédio.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dose,
                    style: fieldStyle,
                    decoration: const InputDecoration(
                      labelText: 'Dose (ex.: 1 comprimido, 20 gotas)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notes,
                    style: fieldStyle,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Observações (ex.: após o café)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Horários',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in _times)
                        InputChip(
                          label: Text(t, style: const TextStyle(fontSize: 22)),
                          onDeleted: () => setState(() => _times.remove(t)),
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.add_alarm_rounded),
                        label: const Text(
                          'Adicionar horário',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed: _addTime,
                      ),
                    ],
                  ),
                  if (_timesError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _timesError!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 60,
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Salvar', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
