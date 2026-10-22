import 'package:calculadora_festivos/domain/calendario.dart';
import 'package:calculadora_festivos/domain/festivos_nacionales.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DateTime viernesSanto(int anio) {
    return festivosNacionales(
      anio,
    ).firstWhere((festivo) => festivo.nombre == 'Viernes Santo').fecha;
  }

  test('el Viernes Santo cae en las fechas conocidas', () {
    expect(viernesSanto(2024), DateTime(2024, 3, 29));
    expect(viernesSanto(2025), DateTime(2025, 4, 18));
    expect(viernesSanto(2026), DateTime(2026, 4, 3));
  });

  test('los nacionales estables son diez y no incluyen fiestas locales', () {
    final festivos = festivosNacionales(2026);
    expect(festivos, hasLength(10));
    expect(
      festivos.every((festivo) => festivo.ambito == Ambito.nacional),
      isTrue,
    );
    expect(
      festivos.map((festivo) => festivo.nombre),
      contains('Fiesta Nacional de España'),
    );
  });
}
