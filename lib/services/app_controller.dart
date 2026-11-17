import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/medicine.dart';

/// Estado do app + persistência local (shared_preferences -> localStorage na web).
class AppController extends ChangeNotifier {
  static const _kElder = 'elder_name';
  static const _kMeds = 'medicines';
  static const _kTaken = 'taken';

  String elderName = '';
  final List<Medicine> medicines = [];

  /// dia ("yyyy-MM-dd") -> chaves de doses já tomadas.
  final Map<String, Set<String>> _taken = {};

  bool loaded = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    elderName = prefs.getString(_kElder) ?? '';

    medicines.clear();
    final medsRaw = prefs.getString(_kMeds);
    if (medsRaw != null) {
      final list = jsonDecode(medsRaw) as List;
      medicines.addAll(
        list.map((e) => Medicine.fromJson(Map<String, dynamic>.from(e as Map))),
      );
    }

    _taken.clear();
    final takenRaw = prefs.getString(_kTaken);
    if (takenRaw != null) {
      final map = jsonDecode(takenRaw) as Map<String, dynamic>;
      map.forEach((day, keys) {
        _taken[day] = (keys as List).cast<String>().toSet();
      });
    }

    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kElder, elderName);
    await prefs.setString(
      _kMeds,
      jsonEncode(medicines.map((m) => m.toJson()).toList()),
    );
    await prefs.setString(
      _kTaken,
      jsonEncode(_taken.map((day, keys) => MapEntry(day, keys.toList()))),
    );
  }

  Future<void> setElderName(String name) async {
    elderName = name.trim();
    notifyListeners();
    await _save();
  }

  Future<void> upsertMedicine(Medicine medicine) async {
    final index = medicines.indexWhere((m) => m.id == medicine.id);
    if (index >= 0) {
      medicines[index] = medicine;
    } else {
      medicines.add(medicine);
    }
    notifyListeners();
    await _save();
  }

  Future<void> removeMedicine(String id) async {
    medicines.removeWhere((m) => m.id == id);
    for (final keys in _taken.values) {
      keys.removeWhere((k) => k.startsWith('$id@'));
    }
    notifyListeners();
    await _save();
  }

  Future<void> toggleTaken(DateTime day, DoseEntry dose) async {
    final keys = _taken.putIfAbsent(dayKey(day), () => <String>{});
    if (!keys.add(dose.key)) keys.remove(dose.key);
    notifyListeners();
    await _save();
  }

  /// Doses previstas para o dia, ordenadas por horário e depois por nome.
  List<DoseEntry> dosesFor(DateTime day) {
    final takenKeys = _taken[dayKey(day)] ?? const <String>{};
    final doses = <DoseEntry>[];
    for (final med in medicines) {
      for (final time in med.times) {
        doses.add(DoseEntry(
          medicine: med,
          time: time,
          taken: takenKeys.contains(DoseEntry.doseKey(med.id, time)),
        ));
      }
    }
    doses.sort((a, b) {
      final byTime = a.time.compareTo(b.time);
      return byTime != 0
          ? byTime
          : a.medicine.name.toLowerCase().compareTo(b.medicine.name.toLowerCase());
    });
    return doses;
  }

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
