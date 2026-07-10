import { UsersService } from '../users/users.service';
import { AuthService } from './auth.service';
import { CambiarPasswordDto } from './dto/cambiar-password.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import type { AuthUser } from './strategies/jwt.strategy';
export declare class AuthController {
    private readonly auth;
    private readonly users;
    constructor(auth: AuthService, users: UsersService);
    register(dto: RegisterDto): Promise<import("./auth.service").AuthResponse>;
    login(dto: LoginDto): Promise<import("./auth.service").AuthResponse>;
    me(user: AuthUser): Promise<{
        id: string;
        nombre: string;
        createdAt: Date;
        updatedAt: Date;
        email: string;
        carrera: string | null;
        universidad: string | null;
    } | null>;
    cambiarPassword(user: AuthUser, dto: CambiarPasswordDto): Promise<void>;
}
