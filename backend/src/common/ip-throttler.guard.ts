import { Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import { Request } from 'express';
import { obtenerIpCliente } from './client-ip';

/**
 * ThrottlerGuard que agrupa por la IP **real** del cliente.
 *
 * El guard por defecto usa `req.ip`, que detrás del proxy de Railway no
 * identifica al usuario de forma estable: el límite terminaba siendo errático
 * y evadible falsificando `X-Forwarded-For`.
 */
@Injectable()
export class IpThrottlerGuard extends ThrottlerGuard {
  protected getTracker(req: Request): Promise<string> {
    return Promise.resolve(obtenerIpCliente(req));
  }
}
