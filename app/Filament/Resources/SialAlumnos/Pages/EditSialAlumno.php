<?php

namespace App\Filament\Resources\SialAlumnos\Pages;

use App\Filament\Resources\SialAlumnos\SialAlumnoResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditSialAlumno extends EditRecord
{
    protected static string $resource = SialAlumnoResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
