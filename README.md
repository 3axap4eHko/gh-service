## Welcome to the *GitHub Service v 0.1*!

### Requirements
	1. PHP 5.4.4+
	2. ssh2 php extension

### Installation
#### On Debian:

    sudo apt-get install php5-dev php-pear re2c libssh2-1-dev && \
    sudo pecl install -af ssh2 && \
    sudo sh -c "echo '; configuration for php SSH2 module\n; priority=50\nextension=ssh2.so\n'>/etc/php5/mods-available/ssh2.ini" && \
    sudo php5enmod ssh2 && \
    sudo apache2ctl graceful

#### MySQL dump configure

Change in ```bin/update.sh``` file line
    #mysqldump -u[username] -p[password] [dbname] | gzip -c | cat>quidcycle.sql.$(date +%d-%m-%Y_%H-%M-%S).tar.gz
strings [username] [password] and [dbname] to actual values