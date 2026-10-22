import 'package:http/http.dart' as http;

import '../domain/calendario.dart';
import '../domain/festivos_nacionales.dart';

const anioPublicadoMin = 2024;
const anioPublicadoMax = 2027;

bool anioConCalendarioPublicado(int anio) {
  return anio >= anioPublicadoMin && anio <= anioPublicadoMax;
}

class FestivosApiException implements Exception {
  FestivosApiException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

class FestivosApi {
  FestivosApi({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;
  static const _base = 'https://festivos.io/v1';

  Future<Calendario> obtener({
    required String ine,
    required int anio,
    required String nombre,
    required String provincia,
  }) async {
    if (!anioConCalendarioPublicado(anio)) {
      return calendarioSoloNacionales(
        anio: anio,
        ine: ine,
        nombre: nombre,
        provincia: provincia,
      );
    }

    final respuesta = await _cliente.get(
      Uri.parse('$_base/$anio/municipio/$ine.json'),
      headers: const {'accept': 'application/json'},
    );
    if (respuesta.statusCode == 404) {
      return calendarioSoloNacionales(
        anio: anio,
        ine: ine,
        nombre: nombre,
        provincia: provincia,
      );
    }
    if (respuesta.statusCode != 200) {
      throw FestivosApiException(
        'La fuente respondió ${respuesta.statusCode}.',
      );
    }
    return calendarioDesdeJson(respuesta.body);
  }

  void cerrar() => _cliente.close();
}
