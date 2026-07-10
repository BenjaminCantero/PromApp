import { JwtService } from '@nestjs/jwt';
import { User } from '@prisma/client';
import { UsersService } from '../users/users.service';
import { CambiarPasswordDto } from './dto/cambiar-password.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
type SafeUser = Omit<User, 'password'>;
export interface AuthResponse {
    accessToken: string;
    user: SafeUser;
}
export declare class AuthService {
    private readonly users;
    private readonly jwt;
    private static readonly SALT_ROUNDS;
    constructor(users: UsersService, jwt: JwtService);
    register(dto: RegisterDto): Promise<AuthResponse>;
    login(dto: LoginDto): Promise<AuthResponse>;
    cambiarPassword(userId: string, dto: CambiarPasswordDto): Promise<void>;
    private buildResponse;
}
export {};
