import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString } from 'class-validator';

export class LoginDto {
  @ApiProperty({ example: 'estudiante@uni.cl' })
  @IsEmail({}, { message: 'El correo no es válido' })
  email: string;

  @ApiProperty({ example: 'miClave123' })
  @IsString()
  password: string;
}
