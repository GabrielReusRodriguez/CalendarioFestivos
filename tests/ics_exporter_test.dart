import 'package:calculadora_festivos/domain/calendario.dart';
import 'package:calculadora_festivos/domain/ics_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('escribe eventos de día completo y escapa el texto', () {
    final calendario = Calendario(
      anio: 2026,
      ine: '28079',
      nombre: 'Madrid',
      provincia: 'Madrid',
      festivos: [
        Festivo(
          fecha: DateTime(2026, 1, 1),
          nombre: 'Fiesta, especial; con \\ y\nsalto',
          ambito: Ambito.nacional,
          tipo: TipoFestivo.fijo,
          fuenteRef: 'BOE-A-2025-21667',
        ),
      ],
    );

    final ics = exportarIcs(
      calendario,
      ahora: DateTime.utc(2026, 10, 22, 18, 0, 0),
    );

    expect(ics, contains('BEGIN:VCALENDAR\r\n'));
    expect(ics, contains('DTSTART;VALUE=DATE:20260101'));
    expect(ics, contains('DTEND;VALUE=DATE:20260102'));
    expect(ics, contains('DTSTAMP:20261022T180000Z'));
    expect(ics, contains(r'SUMMARY:Fiesta\, especial\; con \\ y\nsalto'));
    expect(ics, contains('UID:28079-20260101-0@calculadoradefestivos'));
    expect(ics, endsWith('END:VCALENDAR\r\n'));
    expect(nombreArchivoIcs(calendario), 'festivos-madrid-2026.ics');
  });

  test('el fin exclusivo cruza de mes sin depender del horario de verano', () {
    final calendario = Calendario(
      anio: 2026,
      ine: '01001',
      nombre: 'Alegría-Dulantzi',
      provincia: 'Araba/Álava',
      festivos: [
        Festivo(
          fecha: DateTime(2026, 10, 25),
          nombre: 'Domingo de cambio de hora',
          ambito: Ambito.local,
          tipo: TipoFestivo.fijo,
        ),
      ],
    );

    final ics = exportarIcs(calendario, ahora: DateTime.utc(2026, 1, 1));
    expect(ics, contains('DTSTART;VALUE=DATE:20261025'));
    expect(ics, contains('DTEND;VALUE=DATE:20261026'));
    expect(nombreArchivoIcs(calendario), 'festivos-alegria-dulantzi-2026.ics');
  });
}
