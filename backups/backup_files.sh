#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH=$(dirname "$0")
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/root/bin
YESTERDAY="$(date -d "1 day ago" +%Y%m%d)"

# Source the config file with all path / usernames
if [ -f "${SCRIPT_PATH}/backup.conf" ]; then
        source "${SCRIPT_PATH}/backup.conf"
else 
	echo "Please create a backup.conf from backup.conf-dist with correct variables"
fi

OLDBACKUP="$(date -d "$HISTORY_FILE day ago" +%Y%m%d)"

# On vire les backups d'il y a $HISTORY jours
if [ -d "${LOCAL_BACKUP_DIR_ROOT}/web/${OLDBACKUP}" ]; then
        rm -rf "${LOCAL_BACKUP_DIR_ROOT}/web/${OLDBACKUP}"
fi

# On copie avec hardlink le backup de la veille
if [ ! -d "${LOCAL_BACKUP_DIR_ROOT}/web/${YESTERDAY}" ]; then
        cp -al "${LOCAL_BACKUP_DIR_ROOT}/web/today/" "${LOCAL_BACKUP_DIR_ROOT}/web/${YESTERDAY}"
fi

# et on rsync :)
rsync -aHq --delete --exclude="${RSYNC_EXCLUDE}" "${LOCAL_SOURCE_DIR}" "${LOCAL_BACKUP_DIR_ROOT}/web/today/"
rsync -aHq --delete "${LOCAL_BACKUP_DIR_ROOT}/web/" "${SSH_REMOTE}:${SSH_DESTDIR}/web/"

tar czf "${LOCAL_BACKUP_DIR_ROOT}/etc/whole_etc.$YESTERDAY.tar.gz" /etc/ &> /dev/null
rsync -aHq --delete "${LOCAL_BACKUP_DIR_ROOT}/etc/" "${SSH_REMOTE}:${SSH_DESTDIR}/etc"

