FROM php:8.2-apache

# -------- Paquetes y extensiones PHP típicas para Laravel --------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev libicu-dev \
    libjpeg-dev libfreetype6-dev libssl-dev ca-certificates curl gnupg \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j"$(nproc)" gd zip intl pdo_mysql bcmath opcache

# -------- Apache --------
RUN a2enmod rewrite headers

# DocumentRoot => /app/public
ENV APACHE_DOCUMENT_ROOT=/app/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
      /etc/apache2/sites-available/000-default.conf \
  && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
      /etc/apache2/sites-available/default-ssl.conf

# Permitir .htaccess en /app/public (sin tocar apache2.conf)
RUN printf '%s\n' \
  '<Directory /app/public>' \
  '    AllowOverride All' \
  '    Require all granted' \
  '    Options FollowSymLinks' \
  '</Directory>' \
  > /etc/apache2/conf-available/laravel.conf \
  && a2enconf laravel

# Composer oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Node 20 (para compilar assets en dev/CI si querés)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

# Directorio de trabajo
WORKDIR /app

# Asegura que existan (en imágenes de prod donde copiás código)
# RUN chown -R www-data:www-data /app /var/www

# No seteamos USER -> Apache corre como www-data por defecto
