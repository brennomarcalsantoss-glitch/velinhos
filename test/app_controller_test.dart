import 'package:flutter_test/flutter_test.dart';
import 'package:remedios_idosos/models/medicine.dart';
import 'package:remedios_idosos/services/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Medicine faz round-trip em JSON e ordena horários', () {
    final m = Medicine(
      id: '1',
      name: 'Losartana',
      dose: '1 comprimido',
      times: ['20:00', '08:00'],
    );
    final copy = Medicine.fromJson(m.toJson());
    expect(copy.name, 'Losartana');
    expect(copy.times, ['08:00', '20:00']);
  });

  test('dosesFor ordena por horário e respeita doses tomadas', () async {
    final c = AppController();
    await c.load();
    await c.upsertMedicine(
        Medicine(id: 'a', name: 'B remédio', times: ['12:00', '08:00']));
    await c.upsertMedicine(Medicine(id: 'b', name: 'A remédio', times: ['08:00']));

    final day = DateTime(2026, 11, 17);
    var doses = c.dosesFor(day);
    expect(doses.map((d) => '${d.time} ${d.medicine.name}').toList(), [
      '08:00 A remédio',
      '08:00 B remédio',
      '12:00 B remédio',
    ]);

    await c.toggleTaken(day, doses.first);
    expect(c.dosesFor(day).first.taken, isTrue);
    expect(c.dosesFor(DateTime(2026, 11, 18)).first.taken, isFalse);
  });

  test('dados persistem entre cargas', () async {
    final c = AppController();
    await c.load();
    await c.setElderName('Dona Maria');
    await c.upsertMedicine(Medicine(id: 'x', name: 'Metformina', times: ['07:30']));

    final c2 = AppController();
    await c2.load();
    expect(c2.elderName, 'Dona Maria');
    expect(c2.medicines.single.name, 'Metformina');
  });
}
