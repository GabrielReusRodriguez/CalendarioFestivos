import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/festivos_api.dart';
import '../data/municipio_index.dart';
import '../domain/calendario.dart';
import '../domain/ics_exporter.dart';
import 'exportar_ics.dart';
import 'festivo_tile.dart';
import 'paleta.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.api, this.anioInicial, this.indiceInicial});

  final FestivosApi? api;
  final int? anioInicial;
  final MunicipioIndex? indiceInicial;

  static const busquedaKey = Key('busqueda-municipio');
  static const anioKey = Key('anio');
  static const exportarKey = Key('exportar-ics');
  static const listaKey = Key('lista-calendario');

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _busqueda = TextEditingController();
  final _anioTexto = TextEditingController();
  final _focoBusqueda = FocusNode();
  final _focoAnio = FocusNode();

  late final FestivosApi _api;
  late final bool _apiPropia;

  MunicipioIndex? _indice;
  Municipio? _municipio;
  Calendario? _calendario;
  List<Municipio> _sugerencias = const [];
  var _anio = 2026;
  var _peticion = 0;
  var _cargandoIndice = true;
  var _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _anio = widget.anioInicial ?? DateTime.now().year;
    _anioTexto.text = '$_anio';
    _apiPropia = widget.api == null;
    _api = widget.api ?? FestivosApi();
    _focoAnio.addListener(_alCambiarFocoAnio);
    final indice = widget.indiceInicial;
    if (indice != null) {
      _indice = indice;
      _cargandoIndice = false;
    } else {
      unawaited(_cargarIndice());
    }
  }

  @override
  void dispose() {
    _focoAnio.removeListener(_alCambiarFocoAnio);
    _busqueda.dispose();
    _anioTexto.dispose();
    _focoBusqueda.dispose();
    _focoAnio.dispose();
    if (_apiPropia) _api.cerrar();
    super.dispose();
  }

  Future<void> _cargarIndice() async {
    try {
      final cuerpo = await rootBundle.loadString('assets/municipios.json');
      final indice = MunicipioIndex.desdeJson(cuerpo);
      if (!mounted) return;
      setState(() {
        _indice = indice;
        _cargandoIndice = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargandoIndice = false;
        _error = 'No se pudo cargar el listado de municipios.';
      });
    }
  }

  void _alEscribir(String valor) {
    final indice = _indice;
    if (indice == null) return;
    setState(() {
      _sugerencias = indice.buscar(valor);
      if (_municipio != null && valor != _municipio!.nombre) {
        _municipio = null;
        _calendario = null;
        _error = null;
      }
    });
  }

  void _elegir(Municipio municipio) {
    _busqueda.text = municipio.nombre;
    setState(() {
      _municipio = municipio;
      _sugerencias = const [];
      _error = null;
    });
    _focoBusqueda.unfocus();
    unawaited(_consultar());
  }

  void _alCambiarFocoAnio() {
    if (!_focoAnio.hasFocus && mounted) _confirmarAnio();
  }

  void _confirmarAnio() {
    final anio = int.tryParse(_anioTexto.text.trim());
    if (anio == null || anio < 1900 || anio > 2100) {
      setState(() {
        _error = 'El año tiene que estar entre 1900 y 2100.';
        _calendario = null;
        _cargando = false;
      });
      return;
    }
    if (anio == _anio) return;
    setState(() => _anio = anio);
    unawaited(_consultar());
  }

  void _cambiarAnio(int anio) {
    final limitado = anio.clamp(1900, 2100);
    _anioTexto.text = '$limitado';
    if (limitado == _anio) return;
    setState(() => _anio = limitado);
    unawaited(_consultar());
  }

  Future<void> _consultar() async {
    final municipio = _municipio;
    if (municipio == null) return;
    if (_anio < 1900 || _anio > 2100) return;

    final peticion = ++_peticion;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final calendario = await _api.obtener(
        ine: municipio.ine,
        anio: _anio,
        nombre: municipio.nombre,
        provincia: municipio.provincia,
      );
      if (!mounted || peticion != _peticion) return;
      setState(() {
        _calendario = calendario;
        _cargando = false;
      });
    } on FormatException {
      if (!mounted || peticion != _peticion) return;
      setState(() {
        _cargando = false;
        _calendario = null;
        _error = 'La fuente devolvió un calendario que no se pudo leer.';
      });
    } catch (_) {
      if (!mounted || peticion != _peticion) return;
      setState(() {
        _cargando = false;
        _calendario = null;
        _error =
            'Hace falta conexión para consultar este calendario. Los festivos locales no se inventan sin la fuente.';
      });
    }
  }

  Future<void> _exportar() async {
    final calendario = _calendario;
    if (calendario == null || calendario.festivos.isEmpty) return;
    try {
      await exportarArchivoIcs(
        nombreArchivo: nombreArchivoIcs(calendario),
        contenido: exportarIcs(calendario),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Calendario .ics listo.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo preparar el archivo .ics.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendario = _calendario;
    final titulo = _municipio?.nombre ?? 'Calendario laboral';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      key: HomePage.listaKey,
                      children: [
                        const Text(
                          'CALCULADORA DE FESTIVOS',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 12,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                            color: Paleta.azulejo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          header: true,
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontFamily: 'Figtree',
                              fontSize: 32,
                              height: 1.1,
                              fontWeight: FontWeight.w600,
                              color: Paleta.tinta,
                            ),
                          ),
                        ),
                        if (_municipio != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _municipio!.provincia,
                            style: const TextStyle(
                              fontFamily: 'Figtree',
                              fontSize: 15,
                              color: Paleta.secundario,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _AnioStepper(
                          controller: _anioTexto,
                          focusNode: _focoAnio,
                          onConfirmar: _confirmarAnio,
                          onAnterior: () => _cambiarAnio(_anio - 1),
                          onSiguiente: () => _cambiarAnio(_anio + 1),
                        ),
                        if (calendario != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _resumen(calendario),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Figtree',
                              fontSize: 14,
                              color: Paleta.secundario,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        TextField(
                          key: HomePage.busquedaKey,
                          controller: _busqueda,
                          focusNode: _focoBusqueda,
                          textInputAction: TextInputAction.search,
                          onChanged: _alEscribir,
                          decoration: const InputDecoration(
                            labelText: 'Municipio',
                            hintText: 'Madrid, Sabadell, A Coruña…',
                          ),
                        ),
                        if (_sugerencias.isNotEmpty)
                          _Sugerencias(
                            sugerencias: _sugerencias,
                            onElegir: _elegir,
                          ),
                        if (_mensajeBusquedaVacia) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Ningún municipio con ese nombre.',
                            style: TextStyle(
                              fontFamily: 'Figtree',
                              color: Paleta.secundario,
                            ),
                          ),
                        ],
                        if (_aviso != null) ...[
                          const SizedBox(height: 16),
                          _Banner(
                            texto: _aviso!,
                            esError: _error != null && _calendario == null,
                          ),
                        ],
                        const SizedBox(height: 12),
                        ..._filas(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    key: HomePage.exportarKey,
                    onPressed:
                        calendario == null ||
                            calendario.festivos.isEmpty ||
                            _cargando
                        ? null
                        : () => unawaited(_exportar()),
                    child: const Text('Exportar .ics'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _atribucion(calendario),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      height: 1.4,
                      color: Paleta.secundario,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _mensajeBusquedaVacia {
    return _busqueda.text.trim().isNotEmpty &&
        _sugerencias.isEmpty &&
        _municipio == null &&
        !_cargandoIndice &&
        _indice != null;
  }

  String? get _aviso {
    final calendario = _calendario;
    if (_error != null && calendario == null) return _error;
    if (calendario == null) return null;
    if (calendario.soloNacionales) {
      return 'Los festivos autonómicos y locales de este año no están publicados. Se muestran los nacionales calculados.';
    }
    if (calendario.localesPendientes) {
      return 'Las fiestas locales de este año todavía no están incorporadas. La lista incluye nacionales y autonómicos.';
    }
    return null;
  }

  List<Widget> _filas() {
    const estilo = TextStyle(
      fontFamily: 'Figtree',
      fontSize: 16,
      height: 1.4,
      color: Paleta.secundario,
    );
    if (_cargandoIndice) {
      return const [
        SizedBox(height: 24),
        Text(
          'Cargando municipios…',
          textAlign: TextAlign.center,
          style: estilo,
        ),
      ];
    }
    if (_cargando) {
      return const [
        SizedBox(height: 24),
        Text(
          'Consultando el calendario…',
          textAlign: TextAlign.center,
          style: estilo,
        ),
      ];
    }
    final calendario = _calendario;
    if (calendario == null) {
      return const [
        SizedBox(height: 24),
        Text(
          'Escribe un municipio para ver su calendario laboral.',
          textAlign: TextAlign.center,
          style: estilo,
        ),
      ];
    }
    if (calendario.festivos.isEmpty) {
      return const [
        SizedBox(height: 24),
        Text(
          'Este calendario no tiene festivos publicados.',
          textAlign: TextAlign.center,
          style: estilo,
        ),
      ];
    }
    return [
      for (var indice = 0; indice < calendario.festivos.length; indice++) ...[
        if (indice > 0) const Divider(height: 28, color: Paleta.linea),
        HojaFestivo(festivo: calendario.festivos[indice]),
      ],
    ];
  }

  String _resumen(Calendario calendario) {
    final total = calendario.festivos.length;
    final locales = calendario.locales;
    final festivos = total == 1 ? 'festivo' : 'festivos';
    final localesTexto = locales == 1 ? 'local' : 'locales';
    return '$total $festivos · $locales $localesTexto';
  }

  String _atribucion(Calendario? calendario) {
    if (calendario != null && calendario.soloNacionales) {
      return 'Festivos nacionales calculados, sin fiestas locales.';
    }
    return 'Datos: festivos.io — CC BY 4.0. https://festivos.io';
  }
}

class _AnioStepper extends StatelessWidget {
  const _AnioStepper({
    required this.controller,
    required this.focusNode,
    required this.onConfirmar,
    required this.onAnterior,
    required this.onSiguiente,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onConfirmar;
  final VoidCallback onAnterior;
  final VoidCallback onSiguiente;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Paso(signo: '−', etiqueta: 'Año anterior', onPressed: onAnterior),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: TextField(
              key: HomePage.anioKey,
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              style: const TextStyle(
                fontFamily: 'Besley',
                fontSize: 40,
                height: 1,
                color: Paleta.tinta,
              ),
              decoration: const InputDecoration(
                labelText: 'Año',
                floatingLabelAlignment: FloatingLabelAlignment.center,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: false,
                contentPadding: EdgeInsets.only(top: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Paleta.azulejo, width: 1.5),
                ),
              ),
              onSubmitted: (_) => onConfirmar(),
              onEditingComplete: onConfirmar,
            ),
          ),
        ),
        _Paso(signo: '+', etiqueta: 'Año siguiente', onPressed: onSiguiente),
      ],
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({
    required this.signo,
    required this.etiqueta,
    required this.onPressed,
  });

  final String signo;
  final String etiqueta;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: Paleta.tinta,
        ),
        child: Text(
          signo,
          semanticsLabel: etiqueta,
          style: const TextStyle(
            fontFamily: 'Besley',
            fontSize: 28,
            height: 1,
            color: Paleta.tinta,
          ),
        ),
      ),
    );
  }
}

class _Sugerencias extends StatelessWidget {
  const _Sugerencias({required this.sugerencias, required this.onElegir});

  final List<Municipio> sugerencias;
  final ValueChanged<Municipio> onElegir;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Paleta.hoja,
          border: Border.all(color: Paleta.linea),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          children: [
            for (final municipio in sugerencias)
              TextButton(
                key: Key('municipio-${municipio.ine}'),
                onPressed: () => onElegir(municipio),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Text(
                  '${municipio.nombre} · ${municipio.provincia}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.texto, required this.esError});

  final String texto;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esError ? Paleta.errorFondo : Paleta.aviso,
        border: Border(
          left: BorderSide(
            color: esError ? Paleta.rojo : Paleta.azulejo,
            width: 3,
          ),
        ),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontFamily: 'Figtree',
          fontSize: 14,
          height: 1.4,
          color: Paleta.tinta,
        ),
      ),
    );
  }
}
