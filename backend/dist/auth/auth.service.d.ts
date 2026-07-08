import { JwtService } from '@nestjs/jwt';
import { User } from '@prisma/client';
import { UsersService } from '../users/users.service';
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
    private buildResponse;
}
export {};
