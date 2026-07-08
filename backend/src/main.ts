import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // CORS abierto en desarrollo (la app Flutter consumirá esta API).
  app.enableCors();

  // Validación global: los DTOs con class-validator se aplican solos.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // descarta propiedades no declaradas en el DTO
      forbidNonWhitelisted: true, // y las rechaza con error
      transform: true, // castea payloads a las clases DTO
    }),
  );

  // Documentación Swagger en /docs.
  const config = new DocumentBuilder()
    .setTitle('PromApp API')
    .setDescription('API de gestión de promedios (escala chilena)')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`🚀 PromApp API en http://localhost:${port} (docs: /docs)`);
}
bootstrap();
