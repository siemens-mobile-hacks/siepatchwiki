#!/bin/bash
set -e
if [ -d mediawiki ]; then
  echo "\"mediawiki\" directory alrady exists, skipping mediawiki installation"
  else
mkdir mediawiki|| (echo "Failed to create \"mediawiki\" directory" && exit 1)
curl https://releases.wikimedia.org/mediawiki/1.43/mediawiki-1.43.0.tar.gz -o /tmp/mediawiki-1.43.0.tar.gz || (echo "Failed to download mediawiki" && exit 1)
tar -xvf /tmp/mediawiki-1.43.0.tar.gz -C ./mediawiki --strip-components=1 || (echo "Failed to extract mediawiki" && exit 1)
cd mediawiki/extensions
git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/OOJSPlus
git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/EnhancedUpload
cd ../..
fi
set -a && source .env && set +a
cp LocalSettings.php mediawiki/
ESCAPED_VIRTUAL_HOST="$(printf '%s' "$VIRTUAL_HOST" | sed 's/[.\*\+\?\(\)\|\^\$\[\]{}\\]/\\&/g')"
if [ "$GENERATE_HTTPS_LINKS" == "1" ]; then
  PREFIX='https'
else
  PREFIX='http'
fi
sed -i "s,http://siepatchwiki\.test,${PREFIX}://${ESCAPED_VIRTUAL_HOST},g" mediawiki/LocalSettings.php
mkdir -p data/deleted-files
mkdir -p data/images
chmod -R 777 data/images || true
chmod -R 777 data || true
docker-compose build
docker-compose up -d
docker-compose exec php-fpm chmod 777 /data/images
docker-compose exec php-fpm /scripts/composer-install.sh
docker-compose exec php-fpm sh -c "cd /app/extensions/OOJSPlus && /app/composer.phar install"
docker-compose exec php-fpm sh -c "cd /app/extensions/EnhancedUpload && /app/composer.phar install"
