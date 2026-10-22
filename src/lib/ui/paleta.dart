import 'package:flutter/material.dart';

import '../domain/calendario.dart';

class Paleta {
  static const papel = Color(0xFFF2F5F3);
  static const tinta = Color(0xFF17211E);
  static const rojo = Color(0xFFC4313F);
  static const azulejo = Color(0xFF0F6E6A);
  static const autonomico = Color(0xFF2A5A48);
  static const local = Color(0xFFA86B2A);
  static const linea = Color(0xFFD5DED9);
  static const secundario = Color(0xFF5E6B66);
  static const hoja = Color(0xFFFFFFFF);
  static const aviso = Color(0xFFE7F0EE);
  static const errorFondo = Color(0xFFF8E8EA);
}

Color colorAmbito(Ambito ambito) {
  switch (ambito) {
    case Ambito.nacional:
      return Paleta.rojo;
    case Ambito.autonomico:
      return Paleta.autonomico;
    case Ambito.local:
      return Paleta.local;
  }
}
