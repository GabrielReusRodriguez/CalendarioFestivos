import 'calendario.dart';

/// Domingo de Pascua por el cómputo gregoriano de Meeus.
DateTime domingoDePascua(int anio) {
  final a = anio % 19;
  final b = anio ~/ 100;
  final c = anio % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final mes = (h + l - 7 * m + 114) ~/ 31;
  final dia = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(anio, mes, dia);
}

/// Nacionales de fecha estable. No incluye sustituciones autonómicas ni fiestas locales.
List<Festivo> festivosNacionales(int anio) {
  final pascua = domingoDePascua(anio);
  final viernesSanto = DateTime(pascua.year, pascua.month, pascua.day - 2);

  Festivo fijo(int mes, int dia, String nombre) {
    return Festivo(
      fecha: DateTime(anio, mes, dia),
      nombre: nombre,
      ambito: Ambito.nacional,
      tipo: TipoFestivo.fijo,
    );
  }

  return [
    fijo(1, 1, 'Año Nuevo'),
    fijo(1, 6, 'Epifanía del Señor'),
    Festivo(
      fecha: viernesSanto,
      nombre: 'Viernes Santo',
      ambito: Ambito.nacional,
      tipo: TipoFestivo.movible,
    ),
    fijo(5, 1, 'Fiesta del Trabajo'),
    fijo(8, 15, 'Asunción de la Virgen'),
    fijo(10, 12, 'Fiesta Nacional de España'),
    fijo(11, 1, 'Todos los Santos'),
    fijo(12, 6, 'Día de la Constitución Española'),
    fijo(12, 8, 'Inmaculada Concepción'),
    fijo(12, 25, 'Natividad del Señor'),
  ];
}

Calendario calendarioSoloNacionales({
  required int anio,
  required String ine,
  required String nombre,
  required String provincia,
}) {
  return Calendario(
    anio: anio,
    ine: ine,
    nombre: nombre,
    provincia: provincia,
    festivos: festivosNacionales(anio),
    soloNacionales: true,
  );
}
