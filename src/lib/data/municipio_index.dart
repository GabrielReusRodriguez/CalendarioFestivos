import 'dart:convert';

import '../domain/texto.dart';

class Municipio {
  const Municipio({
    required this.ine,
    required this.nombre,
    required this.provincia,
    required this.ccaa,
  });

  final String ine;
  final String nombre;
  final String provincia;
  final String ccaa;
}

class MunicipioIndex {
  const MunicipioIndex(this.municipios);

  final List<Municipio> municipios;

  factory MunicipioIndex.desdeJson(String cuerpo) {
    final decoded = jsonDecode(cuerpo);
    if (decoded is! List<dynamic>) {
      throw const FormatException('El índice de municipios no es una lista.');
    }
    return MunicipioIndex(
      decoded
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException(
                'Hay un municipio con un formato desconocido.',
              );
            }
            return Municipio(
              ine: item['ine'] as String,
              nombre: item['name'] as String,
              provincia: item['province'] as String,
              ccaa: item['ccaa'] as String,
            );
          })
          .toList(growable: false),
    );
  }

  List<Municipio> buscar(String consulta, {int limite = 8}) {
    final texto = sinAcentos(consulta).trim();
    if (texto.isEmpty) return const [];

    final puntuados = <({int puntos, Municipio municipio})>[];
    for (final municipio in municipios) {
      final nombre = sinAcentos(municipio.nombre);
      final provincia = sinAcentos(municipio.provincia);
      final int? puntos;
      if (nombre == texto) {
        puntos = 0;
      } else if (nombre.startsWith(texto)) {
        puntos = 1;
      } else if (nombre.contains(texto)) {
        puntos = 2;
      } else if (provincia.contains(texto)) {
        puntos = 3;
      } else {
        puntos = null;
      }
      if (puntos != null) {
        puntuados.add((puntos: puntos, municipio: municipio));
      }
    }

    puntuados.sort((a, b) {
      final porPuntos = a.puntos.compareTo(b.puntos);
      if (porPuntos != 0) return porPuntos;
      return sinAcentos(
        a.municipio.nombre,
      ).compareTo(sinAcentos(b.municipio.nombre));
    });

    return puntuados
        .take(limite)
        .map((item) => item.municipio)
        .toList(growable: false);
  }
}
