import 'package:calculadora_festivos/domain/calendario.dart';
import 'package:flutter_test/flutter_test.dart';

import 'soporte.dart';

void main() {
  test('lee el calendario y ordena los festivos por fecha', () {
    final calendario = calendarioDesdeJson(leerFixture('madrid_2026.json'));

    expect(calendario.nombre, 'Madrid');
    expect(calendario.anio, 2026);
    expect(calendario.soloNacionales, isFalse);
    expect(calendario.localesPendientes, isFalse);
    expect(calendario.atribucion, atribucionFestivosIo);
    expect(calendario.festivos.map((festivo) => festivo.nombre), [
      'Año Nuevo',
      'Viernes Santo',
      'Fiesta de la Comunidad de Madrid',
      'San Isidro Labrador',
    ]);
    expect(calendario.festivos[1].tipo, TipoFestivo.movible);
    expect(calendario.festivos[2].ambito, Ambito.autonomico);
    expect(calendario.festivos[3].ambito, Ambito.local);
    expect(calendario.festivos[3].fuenteRef, 'Datos abiertos');
    expect(calendario.festivos.first.fecha, DateTime(2026, 1, 1));
  });

  test('marca las fiestas locales pendientes', () {
    const cuerpo = '''
{
  "year": 2027,
  "local_status": "pending",
  "municipality": {
    "ine": "28079",
    "name": "Madrid",
    "province": {"ine": "28", "name": "Madrid"},
    "ccaa": {"code": "ES-MD", "name": "Comunidad de Madrid"}
  },
  "holidays": [
    {
      "date": "2027-01-01",
      "name": {"es": "Año Nuevo"},
      "level": "national",
      "type": "fixed",
      "source": {"ref": "BOE"}
    }
  ]
}
''';

    final calendario = calendarioDesdeJson(cuerpo);
    expect(calendario.localesPendientes, isTrue);
    expect(calendario.locales, 0);
  });
}
