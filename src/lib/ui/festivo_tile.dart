import 'package:flutter/material.dart';

import '../domain/calendario.dart';
import 'paleta.dart';

const mesesCortos = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

class HojaFestivo extends StatelessWidget {
  const HojaFestivo({required this.festivo, super.key});

  final Festivo festivo;

  @override
  Widget build(BuildContext context) {
    final fuente = festivo.fuenteRef;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _HojaFecha(festivo: festivo),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                festivo.nombre,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 17,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  color: Paleta.tinta,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                festivo.ambito.etiqueta,
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorAmbito(festivo.ambito),
                ),
              ),
              if (fuente != null && fuente.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  fuente,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 12,
                    color: Paleta.secundario,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HojaFecha extends StatelessWidget {
  const _HojaFecha({required this.festivo});

  final Festivo festivo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Paleta.hoja,
        border: Border.all(color: Paleta.linea),
        borderRadius: BorderRadius.circular(2),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: colorAmbito(festivo.ambito)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        festivo.fecha.day.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontFamily: 'Besley',
                          fontSize: 28,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: Paleta.rojo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mesesCortos[festivo.fecha.month - 1],
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 12,
                        letterSpacing: 0.6,
                        color: Paleta.secundario,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
