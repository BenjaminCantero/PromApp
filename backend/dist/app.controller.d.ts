import type { Request } from 'express';
import { AppService } from './app.service';
export declare class AppController {
    private readonly appService;
    constructor(appService: AppService);
    getHello(): string;
    health(): {
        status: string;
        uptime: number;
    };
    debugIp(req: Request): {
        tracker: string;
        confiable: boolean;
        reqIp: string | undefined;
        reqIps: string[];
        headers: {
            'x-envoy-external-address': string | string[] | undefined;
            'x-forwarded-for': string | string[] | undefined;
            'x-real-ip': string | string[] | undefined;
        };
    };
}
