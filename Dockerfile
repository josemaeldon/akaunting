FROM php:7.4-apache
# Note: PHP 7.4 is used to match composer.lock dependency constraints.
# Consider upgrading dependencies to support PHP 8.1+ in the future.

# Instalar dependências do sistema e extensões PHP necessárias para o Akaunting
RUN apt-get update && apt-get install -y \
    zip \
    unzip \
    git \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo_mysql \
        gd \
        zip \
        mbstring \
        xml \
        bcmath \
        opcache \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar Composer
# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1

# Copiar arquivos da aplicação
COPY . /var/www/html/

# Criar arquivo .env e instalar dependências PHP (otimizado para produção)
RUN cd /var/www/html \
    && cp .env.example .env \
    && composer install --no-dev --no-scripts --optimize-autoloader --no-interaction \
    && composer clear-cache \
    && rm .env

# Definir permissões adequadas para diretórios de storage e cache do Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar Apache
RUN a2enmod rewrite

# Configurar PHP para produção
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
} > /usr/local/etc/php/conf.d/opcache.ini

# Definir diretório de trabalho
WORKDIR /var/www/html

# Expor porta 80
EXPOSE 80
