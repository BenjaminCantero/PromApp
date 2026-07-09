import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { AppService } from './app.service';

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
}
