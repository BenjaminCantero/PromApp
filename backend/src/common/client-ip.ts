import { Request } from 'express';

/**
 * IP real del cliente, para usarla como clave del rate limiting.
 *
 * Detrás de un proxy no se puede confiar en `X-Forwarded-For` a secas: el
 * cliente puede enviarla falsificada y, si el proxy la conserva, cada petición
 * caería en un contador distinto (límite evadido).
 *
 * Railway sirve detrás de **Envoy**, que sobrescribe
 * `x-envoy-external-address` con la dirección real del cliente. Al ser
 * *sobrescrita* por el proxy (no añadida), no es falsificable.
 *
 * Orden de preferencia:
 *  1. `x-envoy-external-address`  → no falsificable (Railway).
 *  2. `req.ip` de Express         → según `trust proxy` (entornos conocidos).
 *  3. IP del socket               → último recurso.
 */
export function obtenerIpCliente(req: Request): string {
  const envoy = req.headers['x-envoy-external-address'];
  if (typeof envoy === 'string' && envoy.trim().length > 0) {
    return envoy.trim();
  }

  if (typeof req.ip === 'string' && req.ip.length > 0) {
    return req.ip;
  }

  return req.socket?.remoteAddress ?? 'desconocida';
}

/** `true` si la IP proviene de una cabecera no falsificable por el cliente. */
export function ipEsConfiable(req: Request): boolean {
  const envoy = req.headers['x-envoy-external-address'];
  return typeof envoy === 'string' && envoy.trim().length > 0;
}
