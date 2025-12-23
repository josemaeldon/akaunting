#!/bin/bash
set -e

echo "Starting Akaunting container..."

# Instalar dependências do Composer se ainda não instaladas
if [ ! -d "/var/www/html/vendor" ] || [ ! -f "/var/www/html/vendor/autoload.php" ]; then
    echo "Installing Composer dependencies..."
    cd /var/www/html
    
    # Verificar se .env.example existe
    if [ ! -f ".env.example" ]; then
        echo "ERROR: .env.example file not found!"
        exit 1
    fi
    
    cp .env.example .env
    composer install --no-dev --no-scripts --optimize-autoloader --no-interaction --prefer-dist
    composer clear-cache
    rm -f .env
    echo "Composer dependencies installed successfully."
else
    echo "Composer dependencies already installed."
fi

# Garantir permissões corretas
echo "Setting correct permissions..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

echo "Starting Apache..."
# Iniciar Apache
exec apache2-foreground
