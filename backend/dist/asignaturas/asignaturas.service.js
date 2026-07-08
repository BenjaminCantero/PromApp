"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AsignaturasService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let AsignaturasService = class AsignaturasService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    findAll(userId) {
        return this.prisma.asignatura.findMany({
            where: { userId },
            include: { evaluaciones: true },
            orderBy: { createdAt: 'asc' },
        });
    }
    async findOne(userId, id) {
        const asignatura = await this.prisma.asignatura.findFirst({
            where: { id, userId },
            include: { evaluaciones: true },
        });
        if (!asignatura) {
            throw new common_1.NotFoundException('Asignatura no encontrada');
        }
        return asignatura;
    }
    create(userId, dto) {
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
    async update(userId, id, dto) {
        await this.findOne(userId, id);
        const { evaluaciones, id: _ignore, ...scalars } = dto;
        await this.prisma.$transaction(async (tx) => {
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
                    .filter((x) => !!x);
                await tx.evaluacion.deleteMany({
                    where: { asignaturaId: id, id: { notIn: idsRecibidos } },
                });
                for (const ev of evaluaciones) {
                    const data = toEvaluacionCreate(ev);
                    if (ev.id) {
                        await tx.evaluacion.upsert({
                            where: { id: ev.id },
                            create: { ...data, id: ev.id, asignaturaId: id },
                            update: data,
                        });
                    }
                    else {
                        await tx.evaluacion.create({
                            data: { ...data, asignaturaId: id },
                        });
                    }
                }
            }
        });
        return this.findOne(userId, id);
    }
    async remove(userId, id) {
        await this.findOne(userId, id);
        await this.prisma.asignatura.delete({ where: { id } });
        return { deleted: true };
    }
};
exports.AsignaturasService = AsignaturasService;
exports.AsignaturasService = AsignaturasService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AsignaturasService);
function toEvaluacionCreate(ev) {
    return {
        id: ev.id,
        nombre: ev.nombre,
        porcentaje: ev.porcentaje,
        nota: ev.nota ?? null,
        tipo: ev.tipo ?? null,
        fecha: ev.fecha ? new Date(ev.fecha) : null,
    };
}
//# sourceMappingURL=asignaturas.service.js.map