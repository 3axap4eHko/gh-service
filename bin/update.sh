#!/bin/bash
#copy file to host root directory

# -------------------VARIABLES-----------------------------------------
cd $(dirname $0)
CD=`pwd`
REV="$1"
DATE=$(date +%d-%m-%Y_%H-%M-%S)
FAST_BACKUP_DIR="$CD/last-vhost-backup"
BACKUP_DIR="$CD/backups"
LOCAL_VHOST_DIR="vhost"
VHOST_DIR="$CD/$LOCAL_VHOST_DIR"
REPO_DIR="$CD/repo"
VHOST_TMP="$CD/vhost-$DATE"
# -------------------VARIABLES-----------------------------------------

# -------------------TODO MODIFY-----------------------------------------
#GIT_BRANCH="pull-branch"
#GIT_USERNAME="git-username"
#GIT_PASSWORD="git-password"
#GIT_REPOSITORY="https://$GIT_USERNAME:$GIT_PASSWORD@github.com/:owner/:repo.git"
#DB_USERNAME="db-username"
#DB_PASSWORD="db-password"
#DB_NAME="db-name"
#DB_HOST="localhost"
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

# -------------------VALIDATION-----------------------------------------
    if [ -z $GIT_REPOSITORY ];
    then
        echo 'GIT_REPOSITORY not defined'
        echo 'please edit line with #GIT_REPOSITORY'
        exit 1
    fi
# -------------------VALIDATION-----------------------------------------

    if [ -d $REPO_DIR ];
    then
        echo 'Remove old repo directory'
        rm -rf $REPO_DIR
    fi
    echo 'Create repo directory'
    mkdir -p $REPO_DIR

    if [ ! -d $BACKUP_DIR ];
    then
        echo 'Create backup directory'
        mkdir $BACKUP_DIR
    fi


    git clone $GIT_REPOSITORY $REPO_DIR
    cd $REPO_DIR
    git checkout $GIT_BRANCH
    echo 'Install composer'
    php -r "eval('?>'.file_get_contents('https://getcomposer.org/installer'));"
    php composer.phar install
    echo 'Clean cache'
    php apps/public/console cache:clear --env=prod
    php apps/admin/console cache:clear --env=prod
    chmod 777 apps/public/cache apps/public/logs apps/admin/cache apps/admin/logs
    ln -s ../public/bootstrap.php.cache apps/admin/
    # -------------- PASTE FIRST RUN COMMANDS---------------------------


    # -------------- PASTE FIRST RUN COMMANDS---------------------------
    echo 'After configure launch'
    echo 'update.sh <git commit>'
    exit 0;
# ----------------- FOR FIRST RUN -----------------------------
fi

if [ ! -d "$REPO_DIR" ];
then
    echo "Please make clean install by command without args:"
    echo "update.sh"
    exit 1
fi

# -------------------UPDATE-----------------------------------------
echo 'Create timestamped vhost directory'
mkdir -p $VHOST_TMP
cd $REPO_DIR
git pull
git checkout $GIT_BRANCH
echo 'Copy cuurent state repo dir to timestamped vhost directory'
cp -r $REPO_DIR/* $VHOST_TMP

# -------------------BACKUP-----------------------------------------
echo 'Backup start'
cd $CD
MYSQL_CREDENTIALS="-u$DB_USERNAME "
if [ ! -z $DB_PASSWORD ];
then
    MYSQL_CREDENTIALS="$MYSQL_CREDENTIALS -p$DB_PASSWORD"
fi
echo 'Backuping preupdate database...'
mysqldump $MYSQL_CREDENTIALS --host=$DB_HOST $DB_NAME | gzip -c | cat>$BACKUP_DIR/quidcycle.sql.preupdate.$DATE.tar.gz
if [ -d $VHOST_DIR ];
then
    echo 'Backuping current vhost...'
    tar czf "$BACKUP_DIR/quidcycle.web.$DATE.tar.gz" $LOCAL_VHOST_DIR/*
    if [ -d $FAST_BACKUP_DIR ];
    then
        rm -rf $FAST_BACKUP_DIR
    fi
    TARGET=`ls -l $VHOST_DIR | awk '{print $11}'`
    rm $VHOST_DIR
fi
# -------------------BACKUP-----------------------------------------

ln -s $VHOST_TMP $VHOST_DIR
cd $VHOST_DIR
echo 'Clean cache'
rm -rf apps/public/cache/* apps/admin/cache/*
chmod 777 apps/public/cache apps/public/logs apps/admin/cache apps/admin/logs
echo 'Applying changes'
php apps/public/console assets:install --symlink web
echo 'Backuping postupdate database...'
mysqldump $MYSQL_CREDENTIALS --host=$DB_HOST $DB_NAME | gzip -c | cat>$BACKUP_DIR/quidcycle.sql.postupdate.$DATE.tar.gz
if [ ! -z $TARGET ];
then
    echo 'Create fast backup'
    mv $TARGET $FAST_BACKUP_DIR
fi

# -------------------UPDATE-----------------------------------------