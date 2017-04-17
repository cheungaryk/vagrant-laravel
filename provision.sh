#!/bin/bash

echo "Starting provision…"
echo "Updating system..."
sudo apt-get update

echo "Installing essentials..."

dpkg -s zip unzip python-software-properties curl git &>/dev/null || {
  sudo apt-get install -y zip unzip python-software-properties curl git
}

echo "Installing and configuring MySQL database..."
debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"
apt-get install -y mysql-server mysql-client

mysql -u root -psecret -e "CREATE DATABASE homestead;"
mysql -u root -psecret -e "CREATE USER 'homestead'@'localhost' IDENTIFIED BY 'secret';"
mysql -u root -psecret -e "GRANT ALL PRIVILEGES ON homestead.* TO 'homestead'@'localhost';"
mysql -u root -psecret -e "FLUSH PRIVILEGES;"

dpkg -s apache2 &>/dev/null || {
  echo "Installing Apache web server..."
  sudo apt-get install -y apache2
}

dpkg -s php5 &>/dev/null || {
  echo "Installing PHP5 and components..."
  sudo apt-get install -y php5 libapache2-mod-php5 php5-mcrypt php5-curl php5-mysql php5-cli php5-json php5-mcrypt
}

sudo php5enmod mcrypt
sudo a2enmod rewrite

VHOST=${cat <<EOF
  <VirtualHost *:80>
      DocumentRoot
  "/var/www/html/latest/public"
      <Directory
  "/var/www/html/latest/public">
              Options Indexes FollowSymLinks
  MultiViews
          AllowOverride All
          Require all granted
      </Directory>

  </VirtualHost>
EOF}

echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

sudo service apache2 restart

echo "Installing and configuring composer..."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer self-update --update-keys

echo "Installing and configuring Laravel..."
mkdir -p /var/www/html/latest
composer create-project --prefer-dist laravel/laravel /var/www/html/latest "5.2.*"
sudo chmod -R 777 /var/www/html/latest
sudo chmod -R 777 /var/www/html/latest/storage

echo "Finished provisioning"
