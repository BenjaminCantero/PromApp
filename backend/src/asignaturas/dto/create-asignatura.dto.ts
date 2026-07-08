import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { EvaluacionDto } from './evaluacion.dto';

export class CreateAsignaturaDto {
  @ApiPropertyOptional({ description: 'uuid; opcional en creación' })
  @IsOptional()
  @IsUUID()
  id?: string;

  @ApiProperty({ example: 'Cálculo Diferencial' })
  @IsString()
  nombre: string;

  @ApiPropertyOptional({ example: 'MAT-301' })
  @IsOptional()
  @IsString()
  codigo?: string;

  @ApiPropertyOptional({ example: '2024 - Semestre 1' })
  @IsOptional()
  @IsString()
  semestre?: string;

  @ApiPropertyOptional({ default: false })
  @IsOptional()
  @IsBoolean()
  tieneExamen?: boolean;

  @ApiPropertyOptional({ example: 0.6, minimum: 0, maximum: 1 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1)
  pesoPresentacion?: number;

  @ApiPropertyOptional({ example: 0.4, minimum: 0, maximum: 1 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1)
  pesoExamen?: number;

  @ApiPropertyOptional({ example: 6.0, minimum: 1, maximum: 7 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(7)
  notaExamen?: number;

  @ApiPropertyOptional({ example: 5.5, minimum: 1, maximum: 7 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(7)
  notaEximir?: number;

  @ApiProperty({ type: [EvaluacionDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => EvaluacionDto)
  evaluaciones: EvaluacionDto[];
}
