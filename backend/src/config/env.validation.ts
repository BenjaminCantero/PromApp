/** Secretos de ejemplo que jamás deben usarse fuera de desarrollo. */
const SECRETOS_PROHIBIDOS = [
  'dev-secret-cambiar-en-produccion',
  'cambia-esto-por-un-secreto-largo-y-aleatorio',
  'secret',
  'changeme',
];

const LARGO_MINIMO_SECRETO = 32;

/**
 * Valida las variables de entorno al arrancar. Si algo falta o es inseguro,
 * Nest no levanta: es preferible fallar de inmediato a servir con un
 * `JWT_SECRET` que cualquiera pueda adivinar (permitiría forjar tokens).
 */
export function validateEnv(config: Record<string, unknown>) {
  const errores: string[] = [];

  const databaseUrl = config.DATABASE_URL;
  if (typeof databaseUrl !== 'string' || databaseUrl.length === 0) {
    errores.push('DATABASE_URL es obligatoria');
  }

  const secret = config.JWT_SECRET;
  if (typeof secret !== 'string' || secret.length === 0) {
    errores.push('JWT_SECRET es obligatoria');
  } else if (SECRETOS_PROHIBIDOS.includes(secret)) {
    errores.push(
      'JWT_SECRET es un valor de ejemplo. Genera uno con: ' +
        `node -e "console.log(require('crypto').randomBytes(48).toString('base64url'))"`,
    );
  } else if (secret.length < LARGO_MINIMO_SECRETO) {
    errores.push(
      `JWT_SECRET es demasiado corto (${secret.length}); usa al menos ${LARGO_MINIMO_SECRETO} caracteres`,
    );
  }

  if (errores.length > 0) {
    throw new Error(
      `Configuración inválida:\n  - ${errores.join('\n  - ')}\n` +
        'Revisa tu archivo .env (guíate por .env.example).',
    );
  }

  return config;
}
