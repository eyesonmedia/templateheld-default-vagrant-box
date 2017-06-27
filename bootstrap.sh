#!/usr/bin/env bash
Update () {
    echo "-- Update packages --"
    sudo apt-get update
    sudo apt-get upgrade
}
Update

echo "-- Prepare configuration for MySQL --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

echo "-- Install tools and helpers --"
sudo apt-get install -y --force-yes python-software-properties vim htop curl git npm

echo "-- Install PPA's --"
sudo add-apt-repository ppa:ondrej/php
Update

echo "-- Install NodeJS --"
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -

echo "-- Install packages --"
sudo apt-get install -y --force-yes apache2 mysql-server-5.6 git-core nodejs
sudo apt-get install -y --force-yes php7.0-common php7.0-dev php7.0-json php7.0-opcache php7.0-cli libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-fpm php7.0-curl php7.0-gd php7.0-mcrypt php7.0-mbstring php7.0-bcmath php7.0-zip php7.0-xml
Update

echo "-- Configure PHP &Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini
sudo a2enmod rewrite

echo "-- Creating virtual hosts --"
sudo ln -fs /vagrant/public/ /var/www/public
cat << EOF | sudo tee -a /etc/apache2/sites-available/default.conf
<Directory "/var/www/">
    AllowOverride All
</Directory>

<VirtualHost *:80>
    DocumentRoot /var/www/public
    ServerName dev.templateheld.de
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot /var/www/phpmyadmin
    ServerName pma.templateheld.de
</VirtualHost>
EOF
sudo a2ensite default.conf

echo "-- Restart Apache --"
sudo /etc/init.d/apache2 restart

#echo "-- Install Composer --"
#curl -s https://getcomposer.org/installer | php
#sudo mv composer.phar /usr/local/bin/composer
#sudo chmod +x /usr/local/bin/composer

echo "-- Install Gulp --"
sudo npm install gulp-cli -g
sudo npm npm install gulp -D

echo "-- Install phpMyAdmin --"
wget -k https://files.phpmyadmin.net/phpMyAdmin/4.0.10.11/phpMyAdmin-4.0.10.11-english.tar.gz
sudo tar -xzvf phpMyAdmin-4.0.10.11-english.tar.gz -C /var/www/
sudo rm phpMyAdmin-4.0.10.11-english.tar.gz
sudo mv /var/www/phpMyAdmin-4.0.10.11-english/ /var/www/phpmyadmin

echo "-- Setup databases & preparing database for Magento --"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS templatehelddb"

echo "-- Magento installation --"
# Download and extract latest 1.9.3.3 from https://github.com/OpenMage/magento-mirror/releases > https://github.com/OpenMage/magento-mirror/archive/1.9.3.3.tar.gz
cd /vagrant/public
wget https://github.com/OpenMage/magento-mirror/archive/1.9.3.3.tar.gz
tar -zxvf 1.9.3.3.tar.gz
mv magento-mirror-1.9.3.3/* magento-mirror-1.9.3.3/.htaccess .
chmod -R o+w media var
chmod o+w app/etc
# Clean up downloaded file and extracted dir
rm -rf magento-mirror-1.9.3.3*

echo "-- Magento setup --"
sudo php -f install.php -- --license_agreement_accepted yes \
  --locale de_DE --timezone "Europe/Berlin" --default_currency EUR \
  --db_host localhost --db_name templatehelddb --db_user root --db_pass root \
  --session_save_path /tmp/session \
  --url "http://dev.templateheld.de/" --use_rewrites yes \
  --use_secure no --secure_base_url "http://dev.templateheld.de/" --use_secure_admin no \
  --skip_url_validation yes \
  --admin_lastname Owner --admin_firstname Store --admin_email "admin@templateheld.de" \
  --admin_username admin --admin_password password123
  php -f shell/indexer.php reindexall

# Install n98-magerun
# --------------------
cd /vagrant/public
wget https://raw.github.com/netz98/n98-magerun/master/n98-magerun.phar
chmod +x ./n98-magerun.phar

./n98-magerun.phar cache:clean
./n98-magerun.phar index:reindex:all
