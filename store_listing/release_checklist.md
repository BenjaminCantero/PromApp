# Lista de publicación de PromApp

## Proyecto

- [x] Íconos Android, iOS y web.
- [x] Fuentes empaquetadas para funcionar sin conexión.
- [x] Política de privacidad visible dentro de la app.
- [x] Exportación y eliminación de datos locales.
- [x] Target Android API 36.
- [x] Firma Android release separada de debug.
- [x] AAB y APK release compilados y firmados con la clave de subida.
- [x] SDK Android API 36 y herramientas de línea de comandos instalados.
- [ ] Aceptar personalmente las licencias del SDK con `flutter doctor --android-licenses`.
- [ ] Confirmar el identificador definitivo antes del primer upload.
- [ ] Respaldar `android/app/upload-keystore.jks` y `android/key.properties` en un lugar seguro.
- [ ] Compilar y archivar iOS en macOS con Xcode 26, SDK de iOS 26 y el equipo Apple configurado.

## Google Play Console

- [ ] Crear la aplicación con el identificador definitivo.
- [ ] Activar Play App Signing y subir el AAB firmado.
- [ ] Completar Data Safety según `privacy_declarations.md`.
- [ ] Publicar URL de privacidad y correo de soporte.
- [ ] Completar acceso a la app: no requiere credenciales.
- [ ] Completar audiencia, clasificación de contenido y categoría Educación.
- [ ] Subir gráfico de funciones 1024 × 500 y capturas de teléfono.
- [ ] Ejecutar prueba cerrada de 12 testers durante 14 días si la cuenta personal es nueva.

## App Store Connect

- [ ] Registrar el Bundle ID definitivo.
- [ ] Configurar certificados, equipo y firma automática en Xcode.
- [ ] Crear la ficha con los textos de `app_store_es.md`.
- [ ] Completar App Privacy como Datos no recopilados.
- [ ] Publicar URL de privacidad y soporte.
- [ ] Completar clasificación de edad vigente.
- [ ] Subir capturas requeridas de iPhone.
- [ ] Distribuir primero mediante TestFlight y revisar en dispositivos reales.
