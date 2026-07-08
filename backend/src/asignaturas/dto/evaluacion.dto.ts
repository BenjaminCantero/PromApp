import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsDateString,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

/**
 * Evaluación anidada dentro de una asignatura.
 * El `id` es opcional: si viene (uuid del cliente) se conserva; si no,
 * el servidor genera uno.
 */
export class EvaluacionDto {
  @ApiPropertyOptional({ description: 'uuid; opcional en creación' })
  @IsOptional()
  @IsUUID()
  id?: string;

  @ApiProperty({ example: 'Solemne 1' })
  @IsString()
  nombre: string;

  @ApiProperty({ example: 30, minimum: 0, maximum: 100 })
  @IsNumber()
  @Min(0)
  @Max(100)
  porcentaje: number;

  @ApiPropertyOptional({ example: 5.5, minimum: 1, maximum: 7 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(7)
  nota?: number;

  @ApiPropertyOptional({ example: 'Solemne' })
  @IsOptional()
  @IsString()
  tipo?: string;

  @ApiPropertyOptional({ example: '2026-06-20T00:00:00.000Z' })
  @IsOptional()
  @IsDateString()
  fecha?: string;
}
