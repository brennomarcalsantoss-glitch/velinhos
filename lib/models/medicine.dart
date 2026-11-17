/// Um remédio cadastrado, com um ou mais horários diários (formato "HH:mm").
class Medicine {
  Medicine({
    required this.id,
    required this.name,
    this.dose = '',
    this.notes = '',
    List<String>? times,
  }) : times = List.unmodifiable(List<String>.of(times ?? const <String>[])..sort());

  final String id;
  final String name;
  final String dose;
  final String notes;
  final List<String> times;

  Medicine copyWith({
    String? name,
    String? dose,
    String? notes,
    List<String>? times,
  }) {
    return Medicine(
      id: id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      notes: notes ?? this.notes,
      times: times ?? List<String>.of(this.times),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dose': dose,
        'notes': notes,
        'times': times,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String,
      name: json['name'] as String,
      dose: (json['dose'] as String?) ?? '',
      notes: (json['notes'] as String?) ?? '',
      times: ((json['times'] as List?) ?? const []).cast<String>().toList(),
    );
  }
}

/// Uma dose a ser tomada em um horário específico do dia.
class DoseEntry {
  const DoseEntry({
    required this.medicine,
    required this.time,
    required this.taken,
  });

  final Medicine medicine;
  final String time;
  final bool taken;

  /// Chave única da dose dentro de um dia.
  String get key => doseKey(medicine.id, time);

  static String doseKey(String medicineId, String time) => '$medicineId@$time';
}
