import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportarArchivoIcs({
  required String nombreArchivo,
  required String contenido,
}) async {
  final directorio = await getTemporaryDirectory();
  final archivo = File('${directorio.path}/$nombreArchivo');
  await archivo.writeAsString(contenido, flush: true);
  await Share.shareXFiles([
    XFile(archivo.path, mimeType: 'text/calendar', name: nombreArchivo),
  ]);
}
