"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const swagger_1 = require("@nestjs/swagger");
const app_module_1 = require("./app.module");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    const esProduccion = process.env.NODE_ENV === 'production';
    app.set('trust proxy', 1);
    const origenes = (process.env.CORS_ORIGINS ?? '')
        .split(',')
        .map((o) => o.trim())
        .filter(Boolean);
    app.enableCors({ origin: origenes.length > 0 ? origenes : true });
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
    }));
    const exponerDocs = !esProduccion || process.env.ENABLE_DOCS === 'true';
    if (exponerDocs) {
        const config = new swagger_1.DocumentBuilder()
            .setTitle('PromApp API')
            .setDescription('API de gestión de promedios (escala chilena)')
            .setVersion('1.0')
            .addBearerAuth()
            .build();
        swagger_1.SwaggerModule.setup('docs', app, swagger_1.SwaggerModule.createDocument(app, config));
    }
    const port = process.env.PORT ?? 3000;
    await app.listen(port, '0.0.0.0');
    console.log(`🚀 PromApp API escuchando en :${port}` +
        (exponerDocs ? ' (docs: /docs)' : ' (docs deshabilitados)'));
}
void bootstrap();
//# sourceMappingURL=main.js.map