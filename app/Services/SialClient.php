<?php


namespace App\Services;

use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\Http;
use Illuminate\Http\Client\PendingRequest;

/*Configurar el HTTP client de Laravel:

baseUrl (URL base de SIAL).

Basic Auth (usuario/clave).

Accept: application/json.

Timeouts y reintentos (retry(2, 200)).

Valida el tipo (preinscriptos, alumnos, aspirantes, ingresantes).

Formatea fechas al formato AAAAMMDDHHMM usando la zona horaria configurada.

Expone tres métodos:

listar($tipo): GET /{tipo}/listas/

listarDesde($tipo, $desde): GET /{tipo}/listas/{YmdHi}

listarRango($tipo, $desde, $hasta): GET /{tipo}/listas/{YmdHi}/{YmdHi}

Manejo de errores: si la API responde mal, hace abort(502, 'SIAL error'). Si el tipo es inválido, abort(400, ...).

Devuelve arrays con el JSON (e.g., $resp->json('data') o ->json()).*/

final class SialClient
{
    /** Tipos permitidos según la guía: */
    private array $tipos = ['preinscriptos', 'alumnos', 'aspirantes', 'ingresantes'];

    private function http(): PendingRequest
    {
        return Http::baseUrl(rtrim(config('services.sial.base_url'), '/'))
            ->withBasicAuth(config('services.sial.user'), config('services.sial.pass'))
            ->acceptJson()
            ->timeout(15)
            ->connectTimeout(5)
            ->retry(2, 200);
    }

    /** Formato fecha requerido: AAAAMMDDHHMM (zona configurable) */
    private function fmt(CarbonImmutable $dt): string
    {
        return $dt->setTimezone(config('services.sial.tz'))->format('YmdHi');
    }

    private function validarTipo(string $tipo): string
    {
        $tipo = strtolower(trim($tipo));
        abort_unless(in_array($tipo, $this->tipos, true), 400, "Tipo inválido: $tipo");
        return $tipo;
    }

    /** 3.1 Lista completa: GET /{tipo}/listas/ */
    public function listar(string $tipo): array
    {
        $tipo = $this->validarTipo($tipo);
        $r = $this->http()->get("$tipo/listas/");
        abort_unless($r->successful(), 502, 'SIAL error');
        return $r->json() ?? [];
    }

    /** 3.2 Lista desde fecha: GET /{tipo}/listas/{YmdHi} */
    public function listarDesde(string $tipo, CarbonImmutable $desde): array
    {
        $tipo = $this->validarTipo($tipo);
        $r = $this->http()->get("$tipo/listas/{$this->fmt($desde)}");
        abort_unless($r->successful(), 502, 'SIAL error');
        return $r->json() ?? [];
    }

    /** 3.3 Lista por rango: GET /{tipo}/listas/{YmdHi}/{YmdHi} */
    public function listarRango(string $tipo, CarbonImmutable $desde, CarbonImmutable $hasta): array
    {
        $tipo = $this->validarTipo($tipo);
        abort_unless($desde <= $hasta, 400, 'Rango inválido: desde > hasta');
        $r = $this->http()->get("$tipo/listas/{$this->fmt($desde)}/{$this->fmt($hasta)}");
        abort_unless($r->successful(), 502, 'SIAL error');
        return $r->json() ?? [];
    }
}
