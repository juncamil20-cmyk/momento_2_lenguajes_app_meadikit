# MediaKit — Biblioteca de recursos creativos

Aplicación móvil Flutter para organizar recursos digitales de proyectos Crossmedia en una biblioteca local.

## Problema y objetivo

Fotografías, documentos, piezas gráficas y otros materiales de un proyecto suelen quedar distribuidos entre carpetas y dispositivos. MediaKit permite agruparlos por proyecto, clasificarlos, registrar metadatos y encontrarlos mediante búsqueda y filtros.

Está dirigida a estudiantes y profesionales de Diseño Crossmedia que gestionan varios proyectos creativos. El MVP funciona en el dispositivo: no requiere cuentas, nube ni servicios externos.

## Funcionalidades

Las siete funcionalidades requeridas están implementadas en código. La verificación de uso real en un dispositivo Android queda pendiente.

| Funcionalidad | Estado | Evidencia en la app |
| --- | --- | --- |
| Crear proyectos | Implementada | Mi Biblioteca → Crear proyecto |
| Consultar y listar proyectos | Implementada | Biblioteca y pestaña Proyectos |
| Registrar archivos y asociarlos a un proyecto | Implementada | Detalle del proyecto → Agregar recurso |
| Clasificar recursos y guardar metadatos | Implementada | Categoría, descripción, extensión, tamaño, fecha y dimensiones de imagen disponibles |
| Consultar detalles de recursos | Implementada | Lista del proyecto o pestaña Recursos → Detalle |
| Buscar y filtrar proyectos y recursos | Implementada | Búsqueda general y filtros por categoría |
| Editar y eliminar proyectos y recursos | Implementada | Menú del proyecto y ficha del recurso, con confirmación de borrado |

**Avance funcional:** 7 de 7 funciones del MVP implementadas. Este conteo no representa una evaluación académica completa ni sustituye las pruebas en dispositivo.

## Pantallas y archivos de evidencia

1. **Mi Biblioteca:** lib/features/library/screens/library_screen.dart
2. **Crear / editar proyecto:** lib/features/projects/screens/project_form_screen.dart
3. **Detalle del proyecto:** lib/features/projects/screens/project_detail_screen.dart
4. **Agregar / editar recurso:** lib/features/resources/screens/resource_form_screen.dart
5. **Detalle del recurso:** lib/features/resources/screens/resource_detail_screen.dart

La navegación utiliza una sola pantalla de detalle de proyecto, conserva el proyecto asociado al registrar recursos y vuelve al catálogo correspondiente después de editar o eliminar.

## Persistencia local

- SQLite guarda proyectos y recursos, incluidas sus relaciones.
- Los archivos seleccionados se copian al almacenamiento privado de la aplicación; la base registra esa copia y no la ruta temporal del selector.
- Al eliminar un recurso se elimina su archivo local. Al eliminar un proyecto se eliminan sus recursos y archivos asociados después de confirmación.
- Los contadores y el volumen se calculan a partir de registros reales; no se cargan proyectos de demostración.

## Design System

Los colores, tipografía, tema, botones y campos se centralizan en lib/core/theme/ y lib/core/widgets/media_widgets.dart. La interfaz usa fondo #141311, naranja #F45316, crema #EEE8DB y superficies oscuras, con navegación inferior y diseño desplazable.

Las fuentes Bebas Neue y DM Sans están incluidas localmente en assets/fonts/ junto con sus licencias SIL Open Font License. Se empaquetan con la aplicación y no requieren conexión al ejecutarse. Los archivos originales de Figma (capturas, User Flow, Design System y logos) no aparecen en el repositorio; la interfaz se construyó usando las imágenes compartidas en la conversación.

## Tecnologías y paquetes

- Flutter 3.47.6 / Dart 3.13.5.
- sqflite: base de datos SQLite.
- path_provider: almacenamiento privado de archivos.
- file_picker: selector local de imágenes y recursos.
- image: lectura de dimensiones de imágenes.
- path: construcción de rutas locales.

## Estructura

~~~text
lib/
  app/                 # aplicación y navegación raíz
  core/theme/          # colores y tema compartido
  core/widgets/        # componentes y utilidades visuales
  data/database/       # SQLite
  data/models/         # proyectos y recursos
  data/repositories/   # consultas y operaciones CRUD
  features/library/    # biblioteca y secciones principales
  features/projects/   # formulario y detalle de proyecto
  features/resources/  # formulario y ficha de recurso
  services/            # copia y borrado de archivos locales
~~~

## Instalación y ejecución

Desde la raíz del proyecto:

~~~bash
flutter pub get
flutter run
~~~

Comprobaciones usadas durante el desarrollo:

~~~bash
flutter analyze
flutter test
flutter build apk --debug
~~~

La configuración Android contiene un ajuste acotado al subproyecto file_picker para alinear su destino Kotlin con Java 11; se desactivó la ruta Kotlin Build Tools API porque fallaba al cerrar las cachés incrementales en este entorno.

## Inventario, evidencias y pendientes

- **Mi Biblioteca:** contadores desde SQLite, búsqueda, categorías, proyectos recientes y estados vacíos.
- **Proyectos:** alta, consulta, edición, búsqueda, detalle y eliminación en cascada de recursos.
- **Recursos:** selector de archivos, copia local, categoría, nombre, descripción, tamaño, extensión, fecha y dimensiones cuando aplican.
- **Diseño:** colores y espaciado centralizados; Bebas Neue y DM Sans empaquetadas; logos oficiales pendientes de incorporar.
- **Verificación:** análisis estático, prueba widget de inicio y compilación APK debug. No se probó aún en emulador ni en teléfono físico.
- **PDF académico:** el archivo está disponible en el equipo, pero no se pudo extraer su texto con las herramientas locales; por ello queda pendiente contrastar la rúbrica académica directamente.

## Próximos pasos — Momento 3

1. Probar en un emulador o teléfono: crear, editar y borrar proyectos; registrar archivos de cada formato; cerrar y abrir la app para confirmar persistencia.
2. Incorporar los logos/capturas oficiales al repositorio.
3. Contrastar la rúbrica del PDF y documentar evidencias visuales de ejecución.
4. Revisar tamaños pequeños y tabletas en dispositivos reales.
