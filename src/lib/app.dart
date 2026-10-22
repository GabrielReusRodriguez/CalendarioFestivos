import 'package:flutter/material.dart';

import 'data/festivos_api.dart';
import 'data/municipio_index.dart';
import 'ui/home_page.dart';
import 'ui/paleta.dart';

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({
    super.key,
    this.api,
    this.anioInicial,
    this.indiceInicial,
  });

  final FestivosApi? api;
  final int? anioInicial;
  final MunicipioIndex? indiceInicial;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de festivos',
      debugShowCheckedModeBanner: false,
      theme: temaCalculadora(),
      home: HomePage(
        api: api,
        anioInicial: anioInicial,
        indiceInicial: indiceInicial,
      ),
    );
  }
}

ThemeData temaCalculadora() {
  const texto = TextStyle(fontFamily: 'Figtree', color: Paleta.tinta);
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Paleta.papel,
    fontFamily: 'Figtree',
    colorScheme: const ColorScheme.light(
      primary: Paleta.azulejo,
      onPrimary: Colors.white,
      secondary: Paleta.rojo,
      onSecondary: Colors.white,
      surface: Paleta.papel,
      onSurface: Paleta.tinta,
    ),
    textTheme: const TextTheme(
      bodyMedium: texto,
      bodyLarge: texto,
      titleLarge: texto,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Paleta.azulejo,
      selectionColor: Color(0x330F6E6A),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Paleta.hoja,
      labelStyle: TextStyle(fontFamily: 'Figtree', color: Paleta.secundario),
      hintStyle: TextStyle(fontFamily: 'Figtree', color: Paleta.secundario),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: Paleta.linea),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: Paleta.linea),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: Paleta.azulejo, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Paleta.azulejo,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Paleta.linea,
        disabledForegroundColor: Paleta.secundario,
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Figtree',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Paleta.tinta,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        textStyle: const TextStyle(fontFamily: 'Figtree', fontSize: 16),
      ),
    ),
  );
}
