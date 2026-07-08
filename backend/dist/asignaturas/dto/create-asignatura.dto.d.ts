import { EvaluacionDto } from './evaluacion.dto';
export declare class CreateAsignaturaDto {
    id?: string;
    nombre: string;
    codigo?: string;
    semestre?: string;
    tieneExamen?: boolean;
    pesoPresentacion?: number;
    pesoExamen?: number;
    notaExamen?: number;
    notaEximir?: number;
    evaluaciones: EvaluacionDto[];
}
