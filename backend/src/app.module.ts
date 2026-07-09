import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerModule } from '@nestjs/throttler';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AsignaturasModule } from './asignaturas/asignaturas.module';
import { AuthModule } from './auth/auth.module';
import { IpThrottlerGuard } from './common/ip-throttler.guard';
import { validateEnv } from './config/env.validation';
import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    // Carga .env y lo hace disponible en toda la app.
    // `validate` impide arrancar con un JWT_SECRET débil o ausente.
    ConfigModule.forRoot({ isGlobal: true, validate: validateEnv }),

    // Límite global: 100 peticiones por minuto por IP.
    // Las rutas sensibles (login/registro) lo endurecen con @Throttle.
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 100 }]),

    PrismaModule,
    UsersModule,
    AuthModule,
    AsignaturasModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    // Rate limiting global, agrupando por la IP real del cliente
    // (el guard por defecto usa req.ip, poco fiable detrás del proxy).
    { provide: APP_GUARD, useClass: IpThrottlerGuard },
  ],
})
export class AppModule {}
