<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Sushi\Sushi;

class SialAlumno extends Model
{
    use Sushi;

    protected $schema = [
        'nrodoc'        => 'string',
        'apellido'      => 'string',
        'nombre'        => 'string',
        'tipodoc'       => 'string',
        'fecha_inscri'  => 'string',
        'email'         => 'string',
    ];

    // Para que $model->name exista
    protected $appends = ['name'];

    public function getNameAttribute(): string
    {
        return trim(($this->apellido ?? '').', '.($this->nombre ?? ''));
    }

    public function getRows(): array
    {
        $client = app(\App\Services\SialClient::class);
        $rows = cache()->remember('sial:alumnos', 300, fn () => $client->listar('alumnos'));

        return array_map(fn ($r) => [
            'nrodoc'       => $r['nrodoc']       ?? null,
            'apellido'     => $r['apellido']     ?? null,
            'nombre'       => $r['nombre']       ?? null,
            'tipodoc'      => $r['tipodoc']      ?? null,
            'fecha_inscri' => $r['fecha_inscri'] ?? null,
            'email'        => $r['email']        ?? null,
        ], is_array($rows) ? $rows : []);
    }
}
