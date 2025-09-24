<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SialAlumnoResource\Pages;
use App\Models\SialAlumno;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SialAlumnoResource extends Resource
{
    protected static ?string $model = SialAlumno::class;

    // Antes (incorrecto en v3):
    //    protected static ?string $navigationIcon = 'heroicon-o-user-group';
    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-user-group';

    protected static ?string $navigationLabel = 'Alumnos (SIAL)';
    protected static ?string $pluralModelLabel = 'Alumnos (SIAL)';

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('nrodoc')
                    ->label('DNI')->sortable()->searchable(),
                Tables\Columns\TextColumn::make('apellido')
                    ->sortable()->searchable(),
                Tables\Columns\TextColumn::make('nombre')
                    ->sortable()->searchable(),
                Tables\Columns\TextColumn::make('tipodoc')
                    ->label('Doc.')->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('fecha_inscri')
                    ->label('Fecha insc.')->sortable(),
                Tables\Columns\TextColumn::make('email')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                // Podés agregar filtros luego; con Sushi funcionan los sencillos (where, like, etc.)
            ])
            ->actions([
                Tables\Actions\ViewAction::make(), // solo lectura
            ])
            ->bulkActions([]); // sin bulk delete
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSialAlumnos::route('/'),
            // no exponemos create/edit
        ];
    }
}

