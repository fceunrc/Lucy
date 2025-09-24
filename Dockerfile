# Puedes sobreescribir estos ARG desde docker-compose (build.args)
ARG LOCAL_UID=1001
ARG LOCAL_GID=1001

FROM php:8.2-apache AS base

# ARGs deben redeclararse dentro de la etapa
ARG LOCAL_UID=1001
ARG LOCAL_GID=1001

# Paquetes base + extensiones necesarias para Laravel
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev libicu-dev \
    libpq-dev libjpeg-dev libfreetype6-dev libssl-dev curl gnupg ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" gd zip intl pdo_mysql bcmath opcache

# Apache mods útiles
RUN a2enmod rewrite headers

# Composer oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Node.js 20.x (Nodesource)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get update && apt-get install -y nodejs \
 && rm -rf /var/lib/apt/lists/*

# Crear usuario/grupo de desarrollo (coinciden con el host)
RUN set -eux; \
    if ! getent group "${LOCAL_GID}" >/dev/null; then \
      groupadd -g "${LOCAL_GID}" app; \
    else \
      groupmod -n app "$(getent group "${LOCAL_GID}" | cut -d: -f1)"; \
    fi; \
    if ! getent passwd "${LOCAL_UID}" >/dev/null; then \
      useradd -m -u "${LOCAL_UID}" -g "${LOCAL_GID}" app; \
    else \
      usermod -l app -u "${LOCAL_UID}" -g "${LOCAL_GID}" "$(getent passwd "${LOCAL_UID}" | cut -d: -f1)"; \
    fi

# DocumentRoot a /app/public
ENV APACHE_DOCUMENT_ROOT=/app/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf \
 && sed -ri -e 's!/var/www/!/app/!g' /etc/apache2/apache2.conf

WORKDIR /app
RUN chown -R "${LOCAL_UID}:${LOCAL_GID}" /app /var/www

USER app

# -------------------- Notas de Producción --------------------
# - Podés cambiar USER a www-data (33:33) y usar volúmenes RO.
# - Multi-stage: compilar assets y copiar sólo /public/build.
# - No expongas 3306 si no hace falta. Usa TLS/reverse proxy para HTTP.
