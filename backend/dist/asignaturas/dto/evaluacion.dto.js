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
exports.EvaluacionDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class EvaluacionDto {
    id;
    nombre;
    porcentaje;
    nota;
    tipo;
    fecha;
}
exports.EvaluacionDto = EvaluacionDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'uuid; opcional en creación' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], EvaluacionDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Solemne 1' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], EvaluacionDto.prototype, "nombre", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 30, minimum: 0, maximum: 100 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    (0, class_validator_1.Max)(100),
    __metadata("design:type", Number)
], EvaluacionDto.prototype, "porcentaje", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 5.5, minimum: 1, maximum: 7 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(7),
    __metadata("design:type", Number)
], EvaluacionDto.prototype, "nota", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 'Solemne' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], EvaluacionDto.prototype, "tipo", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: '2026-06-20T00:00:00.000Z' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsDateString)(),
    __metadata("design:type", String)
], EvaluacionDto.prototype, "fecha", void 0);
//# sourceMappingURL=evaluacion.dto.js.map