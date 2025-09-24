<?php

namespace App\Filament\Resources\SialAlumnoResource\Pages;

use App\Filament\Resources\SialAlumnoResource;
use Filament\Resources\Pages\ListRecords;

class ListSialAlumnos extends ListRecords
{
    protected static string $resource = SialAlumnoResource::class;

    protected function getHeaderActions(): array
    {
        return []; // Oculta "Create"
    }
}
