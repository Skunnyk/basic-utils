#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH=$(dirname "$0")
PATH=/sbin:/bin:/usr/sbin:/usr/bin

# Source the config file with all path / usernames
if [ -f "${SCRIPT_PATH}/backup.conf" ]; then
  source "${SCRIPT_PATH}/backup.conf"
else 
	echo "Please create a backup.conf from backup.conf-dist with correct variables"
fi
# MySQL
OLDBACKUP="$(date -d "${HISTORY} day ago" +%Y%m%d)"
LOCAL_BACKUP_DIR="${LOCAL_BACKUP_DIR}/mysql/$(date +%Y%m%d)"

mkdir -p "${LOCAL_BACKUP_DIR}"
for database in $(mysql -e "show databases" --skip-column-names); do
  mysqldump --single-transaction --opt "${database}" > "${LOCAL_BACKUP_DIR}/${database}.sql";
  bzip2 "${LOCAL_BACKUP_DIR}/${database}.sql"
done
cp /etc/mysql/my.cnf "${LOCAL_BACKUP_DIR}/"
rsync -aHq --delete-after "${LOCAL_BACKUP_DIR}" "${SSH_REMOTE}:${SSH_DESTDIR}/mysql"

# Delete old backups
if [ -d "${LOCAL_BACKUP_DIR}/mysql/$OLDBACKUP" ]; then
  rm -rf "${LOCAL_BACKUP_DIR}/mysql/$OLDBACKUP"
fi
