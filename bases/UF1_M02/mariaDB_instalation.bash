#
#MariaDB és la versió de códi obert de MySQL
#
#esborrar versions previes de MySQL
mv -vi /etc/my.cnf /etc/my.cnf.bk
dnf remove mysql-community-libs mysql-community-server
rm -rf /var/lib/mysql
rm -rf /etc/mysql
#
#
# Instal·lar MariaDB
#
# Si no està instal·lat :
# dnf install mariadb mariadb-server

systemctl start mariadb.service 
systemctl enable mariadb.service 
#
#-----------------------------------------------------------------------------------------------------------------------------------------
## Els repositoris de MariaDB vénen amb el Fedora.
#
#Si es vol instal·lar el MySQL_Comunity_Server cal buscar el repositori corresponent  ##
## NO instal·lar MySQL_Comunity_Server a classe, és només info !!!!!
#
#dnf install https://dev.mysql.com/get/mysql57-community-release-fc25-9.noarch.rpm
#
#dnf install mysql-community-server
#
#
#systemctl start mysqld.service
#
#systemctl enable mysqld.service
#
#-----------------------------------------------------------------------------------------------------------------------------------------
#
# Continuació instal·lació de MariaDB
#
# password superusuari mariadb, usuais anònims, accés remot
mysql_secure_installation 
#firewall-cmd --permanent --add-port=3306/tcp
#firewall-cmd --add-port=3306/tcp

mysql -uroot -p
MariaDB--> status
MariaDB--> help
MariaDB--> SHOW DATABASES;
MariaDB--> USE mysql;
MariaDB--> SHOW TABLES;
MariaDB--> status
MariaDB--> SELECT * from user;
#
#Canviar clau de root sense /usr/bin/mysql_secure_installation
#
#mysqladmin -u root password [your_password_here]
#
## Example ##
mysqladmin -u root password myownsecrectpass
#
#
#mysql -u root -p
#
## OR ##
#mysql -h localhost -u root -p
#
#
## CREATE DATABASE ##
mysql> CREATE DATABASE asix_prova;
#
## CREATE USER ##
#mysql> CREATE USER 'asix_user'@'10.0.15.25' IDENTIFIED BY 'password123';
#
## GRANT PERMISSIONS ##
mysql> GRANT ALL ON asis_prova.* TO 'asix_user'@'10.0.15.25';
#
##  FLUSH PRIVILEGES, Tell the server to reload the grant tables  ##
#mysql> FLUSH PRIVILEGES;
#
#
# Test remote connection
#
#
#
#mysql -h 10.0.15.25 -u myusername -p
#
# Si l'Apache no està instal·lat :
dnf install -y httpd
systemctl restart httpd 
#
# Instal·lar phpMyAdmin
dnf install phpmyadmin  #instalació phpmyadmin ( si es queda penjat es pot matar procés)




