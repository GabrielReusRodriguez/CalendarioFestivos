import 'dart:convert';

import 'calendario.dart';
import 'texto.dart';

String exportarIcs(Calendario calendario, {DateTime? ahora}) {
  final momento = (ahora ?? DateTime.now()).toUtc();
  final titulo = 'Festivos de ${calendario.nombre} ${calendario.anio}';
  final lineas = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Calculadora de Festivos//ES',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
    'X-WR-CALNAME:${_escapar(titulo)}',
  ];

  for (var indice = 0; indice < calendario.festivos.length; indice++) {
    final festivo = calendario.festivos[indice];
    final inicio = _ymd(festivo.fecha);
    final fin = _ymd(
      DateTime(festivo.fecha.year, festivo.fecha.month, festivo.fecha.day + 1),
    );
    lineas.addAll([
      'BEGIN:VEVENT',
      'UID:${calendario.ine}-$inicio-$indice@calculadoradefestivos',
      'DTSTAMP:${_dtstamp(momento)}',
      'DTSTART;VALUE=DATE:$inicio',
      'DTEND;VALUE=DATE:$fin',
      'SUMMARY:${_escapar(festivo.nombre)}',
      'DESCRIPTION:${_escapar(_descripcion(festivo))}',
      'END:VEVENT',
    ]);
  }

  lineas.add('END:VCALENDAR');
  return '${lineas.map(_plegar).join('\r\n')}\r\n';
}

String nombreArchivoIcs(Calendario calendario) {
  final base = sinAcentos(
    calendario.nombre,
  ).replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  final slug = base.isEmpty ? calendario.ine : base;
  return 'festivos-$slug-${calendario.anio}.ics';
}

String _descripcion(Festivo festivo) {
  final fuente = festivo.fuenteRef;
  if (fuente == null || fuente.isEmpty) {
    return '${festivo.ambito.etiqueta}. Calculado';
  }
  return '${festivo.ambito.etiqueta}. Fuente: $fuente';
}

String _escapar(String valor) {
  return valor
      .replaceAll('\\', '\\\\')
      .replaceAll('\r\n', r'\n')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\n')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,');
}

String _plegar(String linea) {
  final buffer = StringBuffer();
  var columna = 0;
  for (final rune in linea.runes) {
    final caracter = String.fromCharCode(rune);
    final octetos = utf8.encode(caracter).length;
    if (columna > 0 && columna + octetos > 75) {
      buffer.write('\r\n ');
      columna = 1;
    }
    buffer.write(caracter);
    columna += octetos;
  }
  return buffer.toString();
}

String _ymd(DateTime fecha) {
  final anio = fecha.year.toString().padLeft(4, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');
  return '$anio$mes$dia';
}

String _dtstamp(DateTime momento) {
  final hora = momento.hour.toString().padLeft(2, '0');
  final minuto = momento.minute.toString().padLeft(2, '0');
  final segundo = momento.second.toString().padLeft(2, '0');
  return '${_ymd(momento)}T$hora$minuto${segundo}Z';
}
