import { Controller, Get, NotFoundException, Req } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import type { Request } from 'express';
import { AppService } from './app.service';
import { ipEsConfiable, obtenerIpCliente } from './common/client-ip';

@ApiTags('health')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  /** Healthcheck del hosting: responde 200 si el proceso está vivo. */
  @Get('health')
  @ApiOperation({ summary: 'Estado del servicio' })
  health() {
    return { status: 'ok', uptime: Math.round(process.uptime()) };
  }

  /**
   * Diagnóstico de la IP del cliente detrás del proxy. Sirve para verificar
   * que el rate limiting agrupa por usuario real.
   *
   * Apagado salvo que `ENABLE_IP_DEBUG=true`. No expone datos de usuarios.
   */
  @Get('debug/ip')
  debugIp(@Req() req: Request) {
    if (process.env.ENABLE_IP_DEBUG !== 'true') {
      throw new NotFoundException();
    }
    return {
      tracker: obtenerIpCliente(req),
      confiable: ipEsConfiable(req),
      reqIp: req.ip,
      reqIps: req.ips,
      headers: {
        'x-envoy-external-address': req.headers['x-envoy-external-address'],
        'x-forwarded-for': req.headers['x-forwarded-for'],
        'x-real-ip': req.headers['x-real-ip'],
      },
    };
  }
}
