FROM php:8.2-apache

# Activer les modules Apache
RUN a2enmod rewrite headers

# Installer les extensions PHP nécessaires
RUN docker-php-ext-install pdo pdo_mysql

# Configuration Apache pour CORS
COPY docker/apache/.htaccess /var/www/html/.htaccess

# Configurer les permissions
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 755 /var/www/html/