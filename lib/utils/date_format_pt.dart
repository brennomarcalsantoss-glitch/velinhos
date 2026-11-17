const _weekdays = [
  'segunda-feira',
  'terça-feira',
  'quarta-feira',
  'quinta-feira',
  'sexta-feira',
  'sábado',
  'domingo',
];

const _months = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

/// Ex.: "terça-feira, 17 de novembro de 2026".
String formatLongDatePt(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} de ${_months[d.month - 1]} de ${d.year}';

/// Converte TimeOfDay-like (hora, minuto) em "HH:mm".
String formatHm(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
