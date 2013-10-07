#!/bin/bash
#copy file to host root directory

# -------------------VARIABLES-----------------------------------------
cd $(dirname $0)
CD=`pwd`
REV="$1"
BACKUP_DIR="backups"
VHOST_DIR="$CD/vhost"
DATE=$(date +%d-%m-%Y_%H-%M-%S)
# -------------------VARIABLES-----------------------------------------

# -------------------TODO MODIFY-----------------------------------------
#GIT_USERNAME="git-username"
#GIT_PASSWORD="git-password"
#GIT_REPOSITORY="https://$GIT_USERNAME:$GIT_PASSWORD@github.com/:owner/:repo.git"
#DB_USERNAME="db-username"
#DB_PASSWORD="db-password"
#DB_NAME="db-name"
# -------------------TODO MODIFY-----------------------------------------

# -------------------VALIDATION-----------------------------------------
if [ -z $DB_USERNAME ] || [ -z $DB_NAME ];
then
    echo 'Database credentials is not configured'
    echo 'please edit lines with #DB_USERNAME, #DB_PASSWORD, #DB_NAME'
    exit 1
fi
# -------------------VALIDATION-----------------------------------------


if [ -z $REV ];
then
# ----------------- FOR FIRST RUN -----------------------------

    read -p "Are you sure you want recreate existing instance? [y/N]" -n 1 -r
    if [[ ! $REPLY =~ ^[yY]$ ]];
    then
        echo cancel
        exit 0
    fi

# -------------------VALIDATION-----------------------------------------
    if [ -z $GIT_REPOSITORY ];
    then
        echo 'GIT_REPOSITORY not defined'
        echo 'please edit line with #GIT_REPOSITORY'
        exit 1
    fi
# -------------------VALIDATION-----------------------------------------
    if [ ! -d "$VHOST_DIR" ];
    then
        mkdir $BACKUP_DIR
    fi
    VHOST_TMP="vhost-$DATE"
    git clone $GIT_REPOSITORY $VHOST_TMP
    rm -f $VHOST_DIR
    ln -s $VHOST_TMP $VHOST_DIR
    cd $VHOST_DIR
    git checkout master
    # -------------- PASTE FIRST RUN COMMANDS---------------------------


    # -------------- PASTE FIRST RUN COMMANDS---------------------------
    echo "Please configure project for first run!!!"

# ----------------- FOR FIRST RUN -----------------------------

else

    if [ ! -d "$VHOST_DIR" ];
    then
        echo "Please make clean install by command without args:"
        echo "update.sh"
        exit 1
    fi

# -------------------UPDATE-----------------------------------------

    # -------------------BACKUP-----------------------------------------
    MYSQL_CREDENTIALS="-u$DB_USERNAME "
    if [ ! -z $DB_PASSWORD ];
    then
        MYSQL_CREDENTIALS="$MYSQL_CREDENTIALS -p$DB_PASSWORD"
    fi
    mysqldump $MYSQL_CREDENTIALS $DB_NAME | gzip -c | cat>$BACKUP_DIR/quidcycle.sql.$DATE.tar.gz
    tar czf "$BACKUP_DIR/quidcycle.web.$DATE.tar.gz" $VHOST_DIR
    # -------------------BACKUP-----------------------------------------

    cd $VHOST_DIR
    git pull
    git checkout $REV
    php apps/public/console doctrine:migration:migrate
    php apps/public/console cache:clear --env=prod
    php apps/admin/console cache:clear --env=prod
    php apps/public/console assets:install --symlink web

# -------------------UPDATE-----------------------------------------

fi
