#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH=$(dirname $0)
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/root/bin
YESTERDAY=$(date -d "1 day ago" +%Y%m%d)
HISTORY=3
OLDBACKUP=$(date -d "$HISTORY day ago" +%Y%m%d) 

# Source the config file with all path / usernames
if [ -f $SCRIPT_PATH/backup.conf ]; then
        source $SCRIPT_PATH/backup.conf
else 
	echo "Please create a backup.conf from backup.conf-dist with correct variables"
fi

# On vire les backups d'il y a $HISTORY jours
if [ -d ${LOCAL_BACKUP_DIR}/web/$OLDBACKUP ]; then
        rm -rf ${LOCAL_BACKUP_DIR}/web/$OLDBACKUP
fi

# On copie avec hardlink le backup de la veille
if [ ! -d ${LOCAL_BACKUP_DIR}/web/$YESTERDAY ]; then
        cp -al ${LOCAL_BACKUP_DIR}/web/today/ ${LOCAL_BACKUP_DIR}/web/$YESTERDAY
fi

# et on rsync :)
rsync -aHq --delete ${LOCAL_SOURCE_DIR} ${LOCAL_BACKUP_DIR}/web/today/
rsync -aHq --delete ${LOCAL_BACKUP_DIR}/web/ ${SSH_REMOTE}:${SSH_DESTDIR}/web/

tar czf ${LOCAL_BACKUP_DIR}/etc/whole_etc.$YESTERDAY.tar.gz /etc/ &> /dev/null
rsync -aHq --delete ${LOCAL_BACKUP_DIR}/etc/ ${SSH_REMOTE}:${SSH_DESTDIR}/etc

