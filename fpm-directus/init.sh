#
#	INIT SCRIPT INSPIRED/SNAGGED FROM https://github.com/beevelop/docker-directus/blob/master/init.sh
#
#!/bin/bash
set -ea

DB_PORT=${DB_PORT:-3306}

while ! nc -z ${DB_HOST} ${DB_PORT}; do
  echo "Waiting for Database ${DB_HOST}:${DB_PORT}..."
  sleep 2
done

if [ ! -f /var/www/html/api/config.php ] && [ -n "${DB_HOST}" ]; then
    echo "Setting up database and configuration..."

    su-exec www-data php bin/directus install:config -h "${DB_HOST}" -n "${DB_NAME}" -u "${DB_USER}" -p "${DB_PASS}"
    su-exec www-data php bin/directus install:database
    su-exec www-data php bin/directus install:install -e "${ADMIN_EMAIL}" -p "${ADMIN_PASSWORD}" -t "${SITE_NAME}"
fi

if [ -f /var/www/html/api/config.php ] && [ -z $(nc -z ${MEMCACHE_URL} 11211) ]; then
  echo "memcache server detected... enabling"
  su-exec www-data sed -i "s|'MEMCACHED_SERVER', '127.0.0.1'|'MEMCACHED_SERVER', '${MEMCACHE_URL}'|g" /var/www/html/api/config.php
fi

if [ -f /var/www/html/api/config.php ] && [ -n "${DIRECTUS_ENV}" ] && [ ${DIRECTUS_ENV} != "development" ]; then
  su-exec www-data sed -i "s|'DIRECTUS_ENV', 'development'|'DIRECTUS_ENV', '${DIRECTUS_ENV}'|g" /var/www/html/api/config.php
  MEMCACHE_ENV=$([ "$DIRECTUS_ENV" == "production" ] && echo "prod" || echo "$DIRECTUS_ENV")
  su-exec www-data sed -i "s|'MEMCACHED_ENV_NAMESPACE', 'staging'|'MEMCACHED_ENV_NAMESPACE', '${MEMCACHE_ENV}'|g" /var/www/html/api/config.php
fi

if [ -f /var/www/html/api/configuration.php ] && [ -n "${S3_KEY}" ] && [ -n "${S3_SECRET}" ] && [ -n "${S3_REGION}" ] && [ -n "${S3_BUCKET}" ]; then
    su-exec www-data sed -i "s|'adapter' => 'local'|'adapter' => 's3'|g" /var/www/html/api/configuration.php
    su-exec www-data sed -i "s|'root' => BASE_PATH . '/storage/uploads'|'root' => '${S3_ROOT:-"/"}'|g" /var/www/html/api/configuration.php
    su-exec www-data sed -i "s|'root_url' => '/storage/uploads'|'root_url' => '//s3.amazonaws.com/${S3_BUCKET}${S3_ROOT}media'|g" /var/www/html/api/configuration.php
    su-exec www-data sed -i "s|'root_thumb_url' => '/storage/uploads/thumbs'|'root_thumb_url' => '//s3.amazonaws.com/${S3_BUCKET}${S3_ROOT}thumbs'|g" /var/www/html/api/configuration.php
    su-exec www-data sed -i "s|//   'key'    => 's3-key'|'key'    => '${S3_KEY}'|g" /var/www/html/api/configuration.php
    su-exec www-data sed -i "s|//   'secret' => 's3-key'|'secret'    => '${S3_SECRET}'|g" /var/www/html/api/configuration.php
    su-exec www-data sed -i "s|//   'region' => 's3-region'|'region'    => '${S3_REGION}'|g" /var/www/html/api/configuration.php
    su-exec www-data sed -i "s|//   'version' => 's3-version'|'version'    => 'latest'|g" /var/www/html/api/configuration.php
    su-exec www-data sed -i "s|//   'bucket' => 's3-bucket'|'bucket'    => '${S3_BUCKET}'|g" /var/www/html/api/configuration.php
fi