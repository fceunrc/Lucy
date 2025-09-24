# =================== CONFIGURACIONES (editar según necesidad) ===================
# ARGs para mapear UID/GID del host (desarrollo). En producción puede usar www-data (33:33).
ARG LOCAL_UID=1001
ARG LOCAL_GID=1001

FROM php:8.2-apache AS base

# Dependencias del sistema y extensiones PHP para Laravel
RUN apt-get update && apt-get install -y --no-install-recommends         git unzip libzip-dev libpng-dev libonig-dev libxml2-dev libicu-dev         libpq-dev libjpeg-dev libfreetype6-dev libssl-dev curl gnupg ca-certificates         && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg         && docker-php-ext-install -j$(nproc) gd zip intl pdo_mysql bcmath opcache

# Habilitar Apache mods útiles para Laravel
RUN a2enmod rewrite headers

# Composer (oficial)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Node.js 20.x (Nodesource)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -         && apt-get update && apt-get install -y nodejs         && rm -rf /var/lib/apt/lists/*

# Crear usuario de desarrollo con UID/GID del host
RUN groupadd -g ${LOCAL_GID} app && useradd -m -u ${LOCAL_UID} -g ${LOCAL_GID} app

ENV APACHE_DOCUMENT_ROOT=/app/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf         && sed -ri -e 's!/var/www/!/app/!g' /etc/apache2/apache2.conf

WORKDIR /app

# Permisos básicos
RUN chown -R ${LOCAL_UID}:${LOCAL_GID} /app /var/www

USER ${LOCAL_UID}:${LOCAL_GID}

# =================== NOTAS DE PRODUCCIÓN ===================
# - En producción puede compilar assets y usar un servidor dedicado para servir estáticos.
# - Considere usar opcache con configuración agresiva, y deshabilitar xdebug si lo agrega.
# - Puede cambiar USER a www-data (33:33) y usar volúmenes de solo lectura.
# ===============================================================================
