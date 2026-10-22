import 'package:calculadora_festivos/data/festivos_api.dart';
import 'package:calculadora_festivos/domain/calendario.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'soporte.dart';

void main() {
  test('un año sin publicar no consulta la red', () async {
    final api = FestivosApi(
      cliente: MockClient((_) async => fail('no deberia consultar la red')),
    );

    final calendario = await api.obtener(
      ine: '28079',
      anio: 2023,
      nombre: 'Madrid',
      provincia: 'Madrid',
    );

    expect(calendario.soloNacionales, isTrue);
    expect(calendario.festivos, hasLength(10));
    expect(
      calendario.festivos.every((festivo) => festivo.ambito == Ambito.nacional),
      isTrue,
    );
    expect(
      calendario.festivos
          .firstWhere((festivo) => festivo.nombre == 'Viernes Santo')
          .fecha,
      DateTime(2023, 4, 7),
    );
  });

  test('interpreta el calendario publicado', () async {
    final api = FestivosApi(
      cliente: MockClient((request) async {
        expect(request.url.path, '/v1/2026/municipio/28079.json');
        return http.Response(leerFixture('madrid_2026.json'), 200);
      }),
    );

    final calendario = await api.obtener(
      ine: '28079',
      anio: 2026,
      nombre: 'Madrid',
      provincia: 'Madrid',
    );

    expect(calendario.nombre, 'Madrid');
    expect(calendario.festivos.last.nombre, 'San Isidro Labrador');
  });
}
