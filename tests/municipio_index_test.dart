import 'package:calculadora_festivos/data/municipio_index.dart';
import 'package:calculadora_festivos/domain/texto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MunicipioIndex indice;

  setUpAll(() async {
    final cuerpo = await rootBundle.loadString('assets/municipios.json');
    indice = MunicipioIndex.desdeJson(cuerpo);
  });

  test('alava encuentra municipios de Araba/Álava', () {
    final resultados = indice.buscar('alava');
    expect(resultados, isNotEmpty);
    expect(
      resultados.every(
        (municipio) => sinAcentos(
          '${municipio.nombre} ${municipio.provincia}',
        ).contains('alava'),
      ),
      isTrue,
    );
  });

  test('Madrid exacto queda el primero', () {
    final primero = indice.buscar('Madrid').first;
    expect(primero.ine, '28079');
    expect(primero.nombre, 'Madrid');
  });
}
