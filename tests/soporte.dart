import 'dart:io';

String leerFixture(String nombre) {
  for (final ruta in [
    'test/fixtures/$nombre',
    'tests/fixtures/$nombre',
    '../tests/fixtures/$nombre',
  ]) {
    final archivo = File(ruta);
    if (archivo.existsSync()) return archivo.readAsStringSync();
  }
  throw StateError('No se encuentra el fixture $nombre');
}
