import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { User } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { UsersService } from '../users/users.service';
import { CambiarPasswordDto } from './dto/cambiar-password.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { JwtPayload } from './strategies/jwt.strategy';

/** Usuario sin el campo password (nunca se devuelve al cliente). */
type SafeUser = Omit<User, 'password'>;

export interface AuthResponse {
  accessToken: string;
  user: SafeUser;
}

@Injectable()
export class AuthService {
  private static readonly SALT_ROUNDS = 10;

  constructor(
    private readonly users: UsersService,
    private readonly jwt: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponse> {
    const existe = await this.users.findByEmail(dto.email);
    if (existe) {
      throw new ConflictException('Ya existe una cuenta con ese correo');
    }

    const hash = await bcrypt.hash(dto.password, AuthService.SALT_ROUNDS);
    const user = await this.users.create({
      email: dto.email,
      password: hash,
      nombre: dto.nombre,
    });

    return this.buildResponse(user);
  }

  async login(dto: LoginDto): Promise<AuthResponse> {
    const user = await this.users.findByEmail(dto.email);
    if (!user) {
      throw new UnauthorizedException('Correo o contraseña incorrectos');
    }

    const ok = await bcrypt.compare(dto.password, user.password);
    if (!ok) {
      throw new UnauthorizedException('Correo o contraseña incorrectos');
    }

    return this.buildResponse(user);
  }

  async cambiarPassword(userId: string, dto: CambiarPasswordDto): Promise<void> {
    const user = await this.users.findById(userId);
    if (!user) throw new UnauthorizedException('Usuario no encontrado');

    const ok = await bcrypt.compare(dto.passwordActual, user.password);
    if (!ok) throw new UnauthorizedException('La contraseña actual es incorrecta');

    const hash = await bcrypt.hash(dto.passwordNueva, AuthService.SALT_ROUNDS);
    await this.users.updatePassword(userId, hash);
  }

  /** Firma el token y devuelve el usuario sin password. */
  private buildResponse(user: User): AuthResponse {
    const payload: JwtPayload = { sub: user.id, email: user.email };
    const accessToken = this.jwt.sign(payload);
    const { password: _omit, ...safe } = user;
    return { accessToken, user: safe };
  }
}
