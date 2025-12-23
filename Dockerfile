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

# Copiar e habilitar configuração Apache personalizada
COPY apache-akaunting.conf /etc/apache2/sites-available/akaunting.conf
RUN a2dissite 000-default.conf \
    && a2ensite akaunting.conf

# Tentar instalar dependências PHP (se falhar, será feito no runtime)
# Criar arquivo .env temporário, instalar dependências, e remover .env
RUN cd /var/www/html \
    && if [ -f composer.lock ]; then \
        cp .env.example .env 2>/dev/null || true; \
        timeout 300 composer install --no-dev --no-scripts --optimize-autoloader --no-interaction --prefer-dist 2>/dev/null || echo "Composer install skipped - will run at container startup"; \
        composer clear-cache 2>/dev/null || true; \
        rm -f .env; \
    fi

# Definir permissões adequadas para diretórios de storage e cache do Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar Apache - Habilitar módulos necessários
RUN a2enmod rewrite headers

# Configurar PHP para produção
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
} > /usr/local/etc/php/conf.d/opcache.ini

# Criar script de inicialização
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Instalar dependências do Composer se ainda não instaladas\n\
if [ ! -d "/var/www/html/vendor" ] || [ ! -f "/var/www/html/vendor/autoload.php" ]; then\n\
    echo "Installing Composer dependencies..."\n\
    cd /var/www/html\n\
    cp .env.example .env 2>/dev/null || true\n\
    composer install --no-dev --no-scripts --optimize-autoloader --no-interaction --prefer-dist\n\
    composer clear-cache\n\
    rm -f .env\n\
fi\n\
\n\
# Garantir permissões corretas\n\
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache\n\
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache\n\
\n\
# Iniciar Apache\n\
exec apache2-foreground\n\
' > /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

# Definir diretório de trabalho
WORKDIR /var/www/html

# Expor porta 80
EXPOSE 80

# Usar o script de inicialização como entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

