import 'package:calculadora_festivos/app.dart';
import 'package:calculadora_festivos/data/festivos_api.dart';
import 'package:calculadora_festivos/data/municipio_index.dart';
import 'package:calculadora_festivos/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'soporte.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MunicipioIndex indice;

  setUpAll(() async {
    indice = MunicipioIndex.desdeJson(
      await rootBundle.loadString('assets/municipios.json'),
    );
  });

  testWidgets('pide un municipio y luego muestra su calendario', (tester) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = FestivosApi(
      cliente: MockClient((request) async {
        return http.Response(leerFixture('madrid_2026.json'), 200);
      }),
    );

    await tester.pumpWidget(
      CalculadoraApp(api: api, anioInicial: 2026, indiceInicial: indice),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      find.text('Escribe un municipio para ver su calendario laboral.'),
      findsOneWidget,
    );
    expect(find.text('Exportar .ics'), findsOneWidget);

    tester.view.physicalSize = const Size(360, 700);
    await tester.pump();
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(1280, 2400);
    await tester.pump();

    await tester.enterText(find.byKey(HomePage.busquedaKey), 'Madrid');
    await tester.pump();
    await tester.tap(find.byKey(const Key('municipio-28079')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Año Nuevo'), findsOneWidget);
    expect(find.text('San Isidro Labrador'), findsOneWidget);
    expect(find.text('4 festivos · 1 local'), findsOneWidget);

    await tester.enterText(find.byKey(HomePage.anioKey), '2023');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('no están publicados'), findsWidgets);
    expect(find.text('Viernes Santo'), findsOneWidget);
    expect(find.text('San Isidro Labrador'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
