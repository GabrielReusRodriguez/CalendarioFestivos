import 'dart:convert';

enum Ambito {
  nacional,
  autonomico,
  local;

  String get etiqueta {
    switch (this) {
      case Ambito.nacional:
        return 'Nacional';
      case Ambito.autonomico:
        return 'Autonómico';
      case Ambito.local:
        return 'Local';
    }
  }
}

enum TipoFestivo { fijo, movible, sustituto }

class Festivo {
  const Festivo({
    required this.fecha,
    required this.nombre,
    required this.ambito,
    required this.tipo,
    this.fuenteRef,
    this.fuenteUrl,
  });

  final DateTime fecha;
  final String nombre;
  final Ambito ambito;
  final TipoFestivo tipo;
  final String? fuenteRef;
  final String? fuenteUrl;
}

class Calendario {
  const Calendario({
    required this.anio,
    required this.ine,
    required this.nombre,
    required this.provincia,
    required this.festivos,
    this.ccaa,
    this.localesPendientes = false,
    this.soloNacionales = false,
    this.atribucion,
  });

  final int anio;
  final String ine;
  final String nombre;
  final String provincia;
  final String? ccaa;
  final List<Festivo> festivos;
  final bool localesPendientes;
  final bool soloNacionales;
  final String? atribucion;

  int get locales =>
      festivos.where((festivo) => festivo.ambito == Ambito.local).length;
}

const atribucionFestivosIo = 'festivos.io — CC BY 4.0';

Calendario calendarioDesdeJson(String cuerpo) {
  final decoded = jsonDecode(cuerpo);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('La fuente no devolvió un calendario.');
  }
  return calendarioDesdeMapa(decoded);
}

Calendario calendarioDesdeMapa(Map<String, dynamic> mapa) {
  final anio = mapa['year'];
  if (anio is! int) {
    throw const FormatException('El calendario no indica el año.');
  }
  final municipio = mapa['municipality'];
  if (municipio is! Map<String, dynamic>) {
    throw const FormatException('El calendario no indica el municipio.');
  }
  final provincia = municipio['province'];
  if (provincia is! Map<String, dynamic>) {
    throw const FormatException('El calendario no indica la provincia.');
  }
  final ccaa = municipio['ccaa'];
  final festivosJson = mapa['holidays'];
  if (festivosJson is! List<dynamic>) {
    throw const FormatException('El calendario no trae festivos.');
  }

  final festivos = festivosJson.map((item) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('Hay un festivo con un formato desconocido.');
    }
    return _festivoDesdeMapa(item);
  }).toList();
  festivos.sort((a, b) => a.fecha.compareTo(b.fecha));

  return Calendario(
    anio: anio,
    ine: _textoObligatorio(municipio, 'ine'),
    nombre: _textoObligatorio(municipio, 'name'),
    provincia: _textoObligatorio(provincia, 'name'),
    ccaa: ccaa is Map<String, dynamic> ? ccaa['name'] as String? : null,
    festivos: List.unmodifiable(festivos),
    localesPendientes: mapa['local_status'] == 'pending',
    atribucion: atribucionFestivosIo,
  );
}

Festivo _festivoDesdeMapa(Map<String, dynamic> mapa) {
  final fecha = mapa['date'];
  if (fecha is! String) {
    throw const FormatException('Hay un festivo sin fecha.');
  }
  final nombre = mapa['name'];
  if (nombre is! Map<String, dynamic>) {
    throw const FormatException('Hay un festivo sin nombre.');
  }
  final fuente = mapa['source'];
  return Festivo(
    fecha: _fecha(fecha),
    nombre: _nombre(nombre),
    ambito: _ambito(mapa['level']),
    tipo: _tipo(mapa['type']),
    fuenteRef: fuente is Map<String, dynamic> ? fuente['ref'] as String? : null,
    fuenteUrl: fuente is Map<String, dynamic> ? fuente['url'] as String? : null,
  );
}

DateTime _fecha(String iso) {
  final partes = iso.split('-');
  if (partes.length != 3) {
    throw FormatException('Fecha no válida: $iso');
  }
  final anio = int.tryParse(partes[0]);
  final mes = int.tryParse(partes[1]);
  final dia = int.tryParse(partes[2]);
  if (anio == null || mes == null || dia == null) {
    throw FormatException('Fecha no válida: $iso');
  }
  return DateTime(anio, mes, dia);
}

String _nombre(Map<String, dynamic> nombres) {
  final espanol = nombres['es'];
  if (espanol is String && espanol.isNotEmpty) return espanol;
  for (final valor in nombres.values) {
    if (valor is String && valor.isNotEmpty) return valor;
  }
  throw const FormatException('El festivo no tiene nombre.');
}

Ambito _ambito(Object? valor) {
  switch (valor) {
    case 'national':
      return Ambito.nacional;
    case 'regional':
      return Ambito.autonomico;
    case 'local':
      return Ambito.local;
    default:
      throw FormatException('Ámbito desconocido: $valor');
  }
}

TipoFestivo _tipo(Object? valor) {
  switch (valor) {
    case 'fixed':
      return TipoFestivo.fijo;
    case 'movable':
      return TipoFestivo.movible;
    case 'substitute':
      return TipoFestivo.sustituto;
    default:
      throw FormatException('Tipo de festivo desconocido: $valor');
  }
}

String _textoObligatorio(Map<String, dynamic> mapa, String clave) {
  final valor = mapa[clave];
  if (valor is! String || valor.isEmpty) {
    throw FormatException('Falta el dato $clave.');
  }
  return valor;
}
