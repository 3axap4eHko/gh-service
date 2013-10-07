## Welcome to the *GitHub Service v 0.1*!

### Requirements
	1. PHP 5.4.4+
	2. ssh2 php extension

### Structure
    ..
    /backups/ - directory for store backups
    /vhost/ - deployment directory (is not server document root)
    /update.sh - update script that will be called by hook

### Installation
#### On Debian:

    sudo apt-get install php5-dev php-pear re2c libssh2-1-dev && \
    sudo pecl install -af ssh2 && \
    sudo sh -c "echo '; configuration for php SSH2 module\n; priority=50\nextension=ssh2.so\n'>/etc/php5/mods-available/ssh2.ini" && \
    sudo php5enmod ssh2 && \
    sudo apache2ctl graceful

### Configure
Change in ```bin/update.sh``` file the next lines:
#### GIT repository configure
    #GIT_BRANCH="git-username"
    #GIT_USERNAME="git-username"
    #GIT_PASSWORD="git-password"
    #GIT_REPOSITORY="https://$GIT_USERNAME:$GIT_PASSWORD@github.com/:owner/:repo.git"

#### MySQL dump configure

    #DB_USERNAME="db-username"
    #DB_PASSWORD="db-password"
    #DB_NAME="db-name"

### Usage

    Usage: update.sh [revision] [clean]
    revision - git commit revision
    clean - clean install [0/1] (optional, "0" by default)
