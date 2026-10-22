# Calculadora de festivos

Calcula el calendario laboral de un municipio de España y lo exporta a un archivo `.ics` para importarlo en Google Calendar, Outlook o Apple Calendar.

Los festivos de 2024 a 2027 salen de [festivos.io](https://festivos.io) (CC BY 4.0). En otros años se calculan solo los festivos nacionales.

## Entorno

Flutter está en el devcontainer. No hace falta instalarlo en el sistema. La imagen se define en `.devcontainer/Dockerfile` y Cursor la abre con `.devcontainer/devcontainer.json`.

Si Flutter ya está en el PATH, los scripts lo usan. Si no, construyen y ejecutan la imagen `calculadora-festivos-dev`.

```bash
docker build -t calculadora-festivos-dev -f .devcontainer/Dockerfile .devcontainer
./scripts/test.sh
./scripts/build-web.sh
```

## Entregable

`deploy/web` es la aplicación web lista para publicar. El script de build vacía esa carpeta y copia ahí el resultado de `flutter build web`.

## Estructura

- `.devcontainer`: imagen y configuración del entorno.
- `src`: código Flutter, en Dart. La plataforma incluida es la web.
- `scripts`: pruebas y generación de la web.
- `tests`: pruebas.
- `deploy`: entregable generado.

## Licencias

El código es GPL-3.0. Besley y Figtree se distribuyen bajo la SIL Open Font License; el texto está en `src/assets/fonts`.
