import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  const esProduccion = process.env.NODE_ENV === 'production';

  // Railway (y cualquier PaaS) sirve detrás de un proxy: sin esto, Express ve
  // la IP del proxy en TODAS las peticiones y el ThrottlerGuard trataría a
  // todos los usuarios como uno solo (5 logins/min compartidos → bloqueo
  // masivo). Con `trust proxy` se usa la IP real de `X-Forwarded-For`.
  app.set('trust proxy', 1);

  // CORS: en producción se restringe a los orígenes de CORS_ORIGINS
  // (separados por coma). Sin la variable, se permite cualquier origen
  // (las apps nativas no aplican CORS; esto importa para la build web).
  const origenes = (process.env.CORS_ORIGINS ?? '')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
  app.enableCors({ origin: origenes.length > 0 ? origenes : true });

  // Validación global: los DTOs con class-validator se aplican solos.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // descarta propiedades no declaradas en el DTO
      forbidNonWhitelisted: true, // y las rechaza con error
      transform: true, // castea payloads a las clases DTO
    }),
  );

  // Swagger solo fuera de producción: en producción expondría toda la
  // superficie de la API. Se puede forzar con ENABLE_DOCS=true.
  const exponerDocs = !esProduccion || process.env.ENABLE_DOCS === 'true';
  if (exponerDocs) {
    const config = new DocumentBuilder()
      .setTitle('PromApp API')
      .setDescription('API de gestión de promedios (escala chilena)')
      .setVersion('1.0')
      .addBearerAuth()
      .build();
    SwaggerModule.setup('docs', app, SwaggerModule.createDocument(app, config));
  }

  // '0.0.0.0' es obligatorio en contenedores: escuchar solo en localhost
  // haría que el proxy del hosting nunca alcance la app.
  const port = process.env.PORT ?? 3000;
  await app.listen(port, '0.0.0.0');

  console.log(
    `🚀 PromApp API escuchando en :${port}` +
      (exponerDocs ? ' (docs: /docs)' : ' (docs deshabilitados)'),
  );
}
void bootstrap();
