import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAsignaturaDto } from './dto/create-asignatura.dto';
import { EvaluacionDto } from './dto/evaluacion.dto';
import { UpdateAsignaturaDto } from './dto/update-asignatura.dto';

@Injectable()
export class AsignaturasService {
  constructor(private readonly prisma: PrismaService) {}

  /** Todas las asignaturas del usuario, con sus evaluaciones. */
  findAll(userId: string) {
    return this.prisma.asignatura.findMany({
      where: { userId },
      include: { evaluaciones: true },
      orderBy: { createdAt: 'asc' },
    });
  }

  /** Una asignatura del usuario. 404 si no existe o no es suya. */
  async findOne(userId: string, id: string) {
    const asignatura = await this.prisma.asignatura.findFirst({
      where: { id, userId },
      include: { evaluaciones: true },
    });
    if (!asignatura) {
      throw new NotFoundException('Asignatura no encontrada');
    }
    return asignatura;
  }

  /** Crea una asignatura con sus evaluaciones anidadas. */
  create(userId: string, dto: CreateAsignaturaDto) {
    return this.prisma.asignatura.create({
      data: {
        id: dto.id,
        nombre: dto.nombre,
        codigo: dto.codigo,
        semestre: dto.semestre,
        tieneExamen: dto.tieneExamen ?? false,
        pesoPresentacion: dto.pesoPresentacion ?? 0.6,
        pesoExamen: dto.pesoExamen ?? 0.4,
        notaExamen: dto.notaExamen ?? null,
        notaEximir: dto.notaEximir ?? null,
        userId,
        evaluaciones: {
          create: dto.evaluaciones.map(toEvaluacionCreate),
        },
      },
      include: { evaluaciones: true },
    });
  }

  /**
   * Actualiza la asignatura. Si viene `evaluaciones`, sincroniza el set:
   * borra las que ya no están y hace upsert de las presentes (por id).
   */
  async update(userId: string, id: string, dto: UpdateAsignaturaDto) {
    await this.findOne(userId, id); // valida propiedad (404 si no es suya)

    const { evaluaciones, id: _ignore, ...scalars } = dto;

    await this.prisma.$transaction(async (tx) => {
      // Campos escalares (Prisma ignora los `undefined`).
      await tx.asignatura.update({
        where: { id },
        data: {
          nombre: scalars.nombre,
          codigo: scalars.codigo,
          semestre: scalars.semestre,
          tieneExamen: scalars.tieneExamen,
          pesoPresentacion: scalars.pesoPresentacion,
          pesoExamen: scalars.pesoExamen,
          notaExamen: scalars.notaExamen,
          notaEximir: scalars.notaEximir,
        },
      });

      if (evaluaciones) {
        const idsRecibidos = evaluaciones
          .map((e) => e.id)
          .filter((x): x is string => !!x);

        // Borra las evaluaciones que ya no vienen en el payload.
        await tx.evaluacion.deleteMany({
          where: { asignaturaId: id, id: { notIn: idsRecibidos } },
        });

        // Upsert de cada evaluación recibida.
        for (const ev of evaluaciones) {
          const data = toEvaluacionCreate(ev);
          if (ev.id) {
            await tx.evaluacion.upsert({
              where: { id: ev.id },
              create: { ...data, id: ev.id, asignaturaId: id },
              update: data,
            });
          } else {
            await tx.evaluacion.create({
              data: { ...data, asignaturaId: id },
            });
          }
        }
      }
    });

    return this.findOne(userId, id);
  }

  /** Elimina la asignatura (y sus evaluaciones por cascade). */
  async remove(userId: string, id: string) {
    await this.findOne(userId, id); // valida propiedad
    await this.prisma.asignatura.delete({ where: { id } });
    return { deleted: true };
  }
}

/** Mapea un EvaluacionDto a los datos escalares de Prisma. */
function toEvaluacionCreate(
  ev: EvaluacionDto,
): Prisma.EvaluacionCreateWithoutAsignaturaInput {
  return {
    id: ev.id,
    nombre: ev.nombre,
    porcentaje: ev.porcentaje,
    nota: ev.nota ?? null,
    tipo: ev.tipo ?? null,
    fecha: ev.fecha ? new Date(ev.fecha) : null,
  };
}
