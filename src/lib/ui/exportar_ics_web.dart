import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> exportarArchivoIcs({
  required String nombreArchivo,
  required String contenido,
}) async {
  final bytes = utf8.encode(contenido);
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'text/calendar;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final ancla = web.document.createElement('a') as web.HTMLAnchorElement;
  ancla.href = url;
  ancla.download = nombreArchivo;
  ancla.style.display = 'none';
  final cuerpo = web.document.body;
  if (cuerpo == null) {
    throw StateError('No se pudo preparar la descarga.');
  }
  cuerpo.appendChild(ancla);
  ancla.click();
  ancla.remove();
  web.URL.revokeObjectURL(url);
}
