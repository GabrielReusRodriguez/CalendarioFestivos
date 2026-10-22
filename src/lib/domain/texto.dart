const _sinAcento = {
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'ã': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'õ': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ñ': 'n',
  'ç': 'c',
};

/// Minúsculas y sin tildes, para comparar nombres de municipio.
String sinAcentos(String texto) {
  final buffer = StringBuffer();
  for (final rune in texto.toLowerCase().runes) {
    final caracter = String.fromCharCode(rune);
    buffer.write(_sinAcento[caracter] ?? caracter);
  }
  return buffer.toString();
}
