import { PartialType } from '@nestjs/swagger';
import { CreateAsignaturaDto } from './create-asignatura.dto';

/**
 * Actualización: todos los campos opcionales. Si viene `evaluaciones`,
 * reemplaza el set completo (sincroniza por id).
 */
export class UpdateAsignaturaDto extends PartialType(CreateAsignaturaDto) {}
