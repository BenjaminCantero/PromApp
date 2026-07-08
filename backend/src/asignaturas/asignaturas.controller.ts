import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { AuthUser } from '../auth/strategies/jwt.strategy';
import { AsignaturasService } from './asignaturas.service';
import { CreateAsignaturaDto } from './dto/create-asignatura.dto';
import { UpdateAsignaturaDto } from './dto/update-asignatura.dto';

@ApiTags('asignaturas')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard) // todas las rutas requieren token
@Controller('asignaturas')
export class AsignaturasController {
  constructor(private readonly service: AsignaturasService) {}

  @Get()
  @ApiOperation({ summary: 'Listar mis asignaturas (con evaluaciones)' })
  findAll(@CurrentUser() user: AuthUser) {
    return this.service.findAll(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener una asignatura mía' })
  findOne(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.service.findOne(user.id, id);
  }

  @Post()
  @ApiOperation({ summary: 'Crear asignatura con evaluaciones' })
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateAsignaturaDto) {
    return this.service.create(user.id, dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar asignatura (sincroniza evaluaciones)' })
  update(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateAsignaturaDto,
  ) {
    return this.service.update(user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar asignatura' })
  remove(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.service.remove(user.id, id);
  }
}
