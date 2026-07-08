import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAsignaturaDto } from './dto/create-asignatura.dto';
import { UpdateAsignaturaDto } from './dto/update-asignatura.dto';
export declare class AsignaturasService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    findAll(userId: string): Prisma.PrismaPromise<({
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
    findOne(userId: string, id: string): Promise<{
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
    create(userId: string, dto: CreateAsignaturaDto): Prisma.Prisma__AsignaturaClient<{
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
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    update(userId: string, id: string, dto: UpdateAsignaturaDto): Promise<{
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
    remove(userId: string, id: string): Promise<{
        deleted: boolean;
    }>;
}
