#!/bin/bash
#copy file to host root directory
cd $(dirname $0)
CD=`pwd`
REV="$1"
CLEAN="$2"
BACKUP_DIR="$CD/backups"
DATE=$(date +%d-%m-%Y_%H-%M-%S)
#REPOSITORY="https://github.com/:owner/:repo.git"
#DB_USERNAME=username
#DB_PASSWORD=username
#DB_NAME=dbname

if [ -z $REV ];
then
    echo Error: no revision commit found
    echo Usage: update.sh [revision] [clean]
    echo '   revision - git commit revision'
    echo '   clean - clean install [0/1], "0" by default (optional)'
    exit 1
fi
if [ -z $REPOSITORY ];
then
    echo 'REPOSITORY not defined'
    echo 'please edit line # REPOSITORY="https://github.com/:owner/:repo.git"'
    exit 1
fi

if [ -z $DB_USERNAME ] || [ -z $DB_PASSWORD ] || [ -z $DB_NAME ];
then
    echo 'Database credentials is not configured'
    echo 'please edit lines #DB_USERNAME=username, #DB_PASSWORD=username, #DB_NAME=dbname'
    exit 1
fi

mysqldump -u$DB_USERNAME -pDB_PASSWORD $DB_NAME | gzip -c | cat>vhost/quidcycle.sql.$DATE.tar.gz
tar czf "$BACKUP_DIR/quidcycle.web.$DATE.tar.gz" vhost/
if [ ! -z $CLEAN ] && [ $CLEAN == "1" ];
then
    VHOST="vhost-$DATE"
    git clone $REPOSITORY $VHOST
    rm vhost
    ln -s $VHOST vhost
    cd vhost
else
    cd vhost
    git pull
fi

git checkout $REV
php apps/public/console doctrine:migration:migrate
php apps/public/console cache:clear --env=prod
php apps/admin/console cache:clear --env=prod
php apps/public/console assets:install --symlink web