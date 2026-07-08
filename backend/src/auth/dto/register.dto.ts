import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, MinLength } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'estudiante@uni.cl' })
  @IsEmail({}, { message: 'El correo no es válido' })
  email: string;

  @ApiProperty({ example: 'miClave123', minLength: 6 })
  @IsString()
  @MinLength(6, { message: 'La contraseña debe tener al menos 6 caracteres' })
  password: string;

  @ApiProperty({ example: 'Ana Pérez' })
  @IsString()
  @MinLength(2, { message: 'Ingresa tu nombre' })
  nombre: string;
}
