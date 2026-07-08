import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AsignaturasModule } from './asignaturas/asignaturas.module';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    // Carga .env y lo hace disponible en toda la app.
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    UsersModule,
    AuthModule,
    AsignaturasModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
