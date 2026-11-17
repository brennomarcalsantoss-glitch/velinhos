import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../utils/date_format_pt.dart';

/// Cartão com a agenda de remédios do dia. É este widget que é capturado
/// como imagem para compartilhar (fundo branco, fonte grande, alto contraste).
class AgendaCard extends StatelessWidget {
  const AgendaCard({
    super.key,
    required this.date,
    required this.elderName,
    required this.doses,
    this.onToggle,
  });

  final DateTime date;
  final String elderName;
  final List<DoseEntry> doses;

  /// Se nulo, as linhas não são clicáveis.
  final void Function(DoseEntry dose)? onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = doses.where((d) => d.taken).length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medication_rounded, size: 36, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Remédios do dia',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (elderName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              elderName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            formatLongDatePt(date),
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const Divider(height: 28, thickness: 2),
          if (doses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Nenhum remédio cadastrado.',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
            )
          else
            for (final dose in doses) _DoseRow(dose: dose, onToggle: onToggle),
          if (doses.isNotEmpty) ...[
            const Divider(height: 28, thickness: 2),
            Text(
              'Tomados: $done de ${doses.length}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DoseRow extends StatelessWidget {
  const _DoseRow({required this.dose, this.onToggle});

  final DoseEntry dose;
  final void Function(DoseEntry dose)? onToggle;

  @override
  Widget build(BuildContext context) {
    final taken = dose.taken;
    final med = dose.medicine;
    final color = taken ? Colors.green.shade800 : Colors.black87;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              dose.time,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color,
                    decoration: taken ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (med.dose.isNotEmpty)
                  Text(
                    med.dose,
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                if (med.notes.isNotEmpty)
                  Text(
                    med.notes,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            taken ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 36,
            color: taken ? Colors.green.shade700 : Colors.black38,
          ),
        ],
      ),
    );

    if (onToggle == null) return row;
    return InkWell(
      onTap: () => onToggle!(dose),
      borderRadius: BorderRadius.circular(8),
      child: row,
    );
  }
}
