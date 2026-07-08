import { Module } from '@nestjs/common';
import { AsignaturasController } from './asignaturas.controller';
import { AsignaturasService } from './asignaturas.service';

@Module({
  controllers: [AsignaturasController],
  providers: [AsignaturasService],
})
export class AsignaturasModule {}
