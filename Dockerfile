FROM devsu/tao:latest

# Copy custom logo files
COPY logo_white.svg /var/www/html/tao/views/img/tao-logo.png
COPY logo_white.svg /var/www/html/tao/views/img/logo_tao.png
COPY logo_white.svg /var/www/html/tao/views/img/tao_logo_big.png
COPY logo_white.svg /var/www/html/tao/views/img/tao-logo-alpha.png
COPY logo_white.svg /var/www/html/tao/views/img/tao-logo-beta.png

# Clear cache
RUN find /var/www/html -type d -name cache -exec rm -rf {}/* \; 2>/dev/null || true

EXPOSE 9000
CMD ["php-fpm"]
