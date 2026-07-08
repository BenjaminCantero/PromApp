-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "carrera" TEXT,
    "universidad" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "asignaturas" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "codigo" TEXT,
    "semestre" TEXT,
    "tieneExamen" BOOLEAN NOT NULL DEFAULT false,
    "pesoPresentacion" DOUBLE PRECISION NOT NULL DEFAULT 0.6,
    "pesoExamen" DOUBLE PRECISION NOT NULL DEFAULT 0.4,
    "notaExamen" DOUBLE PRECISION,
    "notaEximir" DOUBLE PRECISION,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "asignaturas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "evaluaciones" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "porcentaje" DOUBLE PRECISION NOT NULL,
    "nota" DOUBLE PRECISION,
    "tipo" TEXT,
    "fecha" TIMESTAMP(3),
    "asignaturaId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "evaluaciones_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "asignaturas_userId_idx" ON "asignaturas"("userId");

-- CreateIndex
CREATE INDEX "evaluaciones_asignaturaId_idx" ON "evaluaciones"("asignaturaId");

-- AddForeignKey
ALTER TABLE "asignaturas" ADD CONSTRAINT "asignaturas_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evaluaciones" ADD CONSTRAINT "evaluaciones_asignaturaId_fkey" FOREIGN KEY ("asignaturaId") REFERENCES "asignaturas"("id") ON DELETE CASCADE ON UPDATE CASCADE;
