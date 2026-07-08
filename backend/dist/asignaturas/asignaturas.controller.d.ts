import type { AuthUser } from '../auth/strategies/jwt.strategy';
import { AsignaturasService } from './asignaturas.service';
import { CreateAsignaturaDto } from './dto/create-asignatura.dto';
import { UpdateAsignaturaDto } from './dto/update-asignatura.dto';
export declare class AsignaturasController {
    private readonly service;
    constructor(service: AsignaturasService);
    findAll(user: AuthUser): import("@prisma/client").Prisma.PrismaPromise<({
        evaluaciones: {
            id: string;
            nombre: string;
            porcentaje: number;
            nota: number | null;
            tipo: string | null;
            fecha: Date | null;
            createdAt: Date;
            updatedAt: Date;
            asignaturaId: string;
        }[];
    } & {
        id: string;
        nombre: string;
        codigo: string | null;
        semestre: string | null;
        tieneExamen: boolean;
        pesoPresentacion: number;
        pesoExamen: number;
        notaExamen: number | null;
        notaEximir: number | null;
        userId: string;
        createdAt: Date;
        updatedAt: Date;
    })[]>;
    findOne(user: AuthUser, id: string): Promise<{
        evaluaciones: {
            id: string;
            nombre: string;
            porcentaje: number;
            nota: number | null;
            tipo: string | null;
            fecha: Date | null;
            createdAt: Date;
            updatedAt: Date;
            asignaturaId: string;
        }[];
    } & {
        id: string;
        nombre: string;
        codigo: string | null;
        semestre: string | null;
        tieneExamen: boolean;
        pesoPresentacion: number;
        pesoExamen: number;
        notaExamen: number | null;
        notaEximir: number | null;
        userId: string;
        createdAt: Date;
        updatedAt: Date;
    }>;
    create(user: AuthUser, dto: CreateAsignaturaDto): import("@prisma/client").Prisma.Prisma__AsignaturaClient<{
        evaluaciones: {
            id: string;
            nombre: string;
            porcentaje: number;
            nota: number | null;
            tipo: string | null;
            fecha: Date | null;
            createdAt: Date;
            updatedAt: Date;
            asignaturaId: string;
        }[];
    } & {
        id: string;
        nombre: string;
        codigo: string | null;
        semestre: string | null;
        tieneExamen: boolean;
        pesoPresentacion: number;
        pesoExamen: number;
        notaExamen: number | null;
        notaEximir: number | null;
        userId: string;
        createdAt: Date;
        updatedAt: Date;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, import("@prisma/client").Prisma.PrismaClientOptions>;
    update(user: AuthUser, id: string, dto: UpdateAsignaturaDto): Promise<{
        evaluaciones: {
            id: string;
            nombre: string;
            porcentaje: number;
            nota: number | null;
            tipo: string | null;
            fecha: Date | null;
            createdAt: Date;
            updatedAt: Date;
            asignaturaId: string;
        }[];
    } & {
        id: string;
        nombre: string;
        codigo: string | null;
        semestre: string | null;
        tieneExamen: boolean;
        pesoPresentacion: number;
        pesoExamen: number;
        notaExamen: number | null;
        notaEximir: number | null;
        userId: string;
        createdAt: Date;
        updatedAt: Date;
    }>;
    remove(user: AuthUser, id: string): Promise<{
        deleted: boolean;
    }>;
}
