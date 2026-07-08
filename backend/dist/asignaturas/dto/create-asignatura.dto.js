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
exports.CreateAsignaturaDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_transformer_1 = require("class-transformer");
const class_validator_1 = require("class-validator");
const evaluacion_dto_1 = require("./evaluacion.dto");
class CreateAsignaturaDto {
    id;
    nombre;
    codigo;
    semestre;
    tieneExamen;
    pesoPresentacion;
    pesoExamen;
    notaExamen;
    notaEximir;
    evaluaciones;
}
exports.CreateAsignaturaDto = CreateAsignaturaDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'uuid; opcional en creación' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], CreateAsignaturaDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Cálculo Diferencial' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAsignaturaDto.prototype, "nombre", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 'MAT-301' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAsignaturaDto.prototype, "codigo", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: '2024 - Semestre 1' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAsignaturaDto.prototype, "semestre", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ default: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], CreateAsignaturaDto.prototype, "tieneExamen", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 0.6, minimum: 0, maximum: 1 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    (0, class_validator_1.Max)(1),
    __metadata("design:type", Number)
], CreateAsignaturaDto.prototype, "pesoPresentacion", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 0.4, minimum: 0, maximum: 1 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    (0, class_validator_1.Max)(1),
    __metadata("design:type", Number)
], CreateAsignaturaDto.prototype, "pesoExamen", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 6.0, minimum: 1, maximum: 7 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(7),
    __metadata("design:type", Number)
], CreateAsignaturaDto.prototype, "notaExamen", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 5.5, minimum: 1, maximum: 7 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(7),
    __metadata("design:type", Number)
], CreateAsignaturaDto.prototype, "notaEximir", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: [evaluacion_dto_1.EvaluacionDto] }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.ValidateNested)({ each: true }),
    (0, class_transformer_1.Type)(() => evaluacion_dto_1.EvaluacionDto),
    __metadata("design:type", Array)
], CreateAsignaturaDto.prototype, "evaluaciones", void 0);
//# sourceMappingURL=create-asignatura.dto.js.map