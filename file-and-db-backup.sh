#!/bin/sh

# setting
BACKUP_DIST_DIR="my-backup-directry"
# backup source directory ex /home/username/target
BACKUP_SRC_DIR="backup-source-directory"

DBBACKUP_DIR="${BACKUP_DIST_DIR}/db"


DB_NAMES="mysql-dbname"
USER_NAME="mysql-db-username"
DB_PASS="mysql-dbuser-pass"


# 1. file backup
script_dir=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

cd $script_dir

rsync -a --delete ${BACKUP_SRC_DIR} ${BACKUP_DIST_DIR}

# 2. make DB lotate directory
count=10

# 2-1. remove oldest backup directory
if [ -e ${DBBACKUP_DIR}_${count} ];
then
    rm -fr ${DBBACKUP_DIR}_${count}
fi

# 2-2. lotate
while [ $count -ge 1 ];
do
    next=`expr $count - 1`
    if [ -e ${DBBACKUP_DIR}_${next} ];
    then
        echo "mv ${DBBACKUP_DIR}_${next} ${DBBACKUP_DIR}_${count}"
        mv ${DBBACKUP_DIR}_${next} ${DBBACKUP_DIR}_${count}
    else
        echo "Warning: Directory '${DBBACKUP_DIR}_${count}' is not found."
    fi
    count=`expr $count - 1`
done

# 2-3. make new backup directory
DBBACKUP_DIR_0=${DBBACKUP_DIR}_0

mkdir $DBBACKUP_DIR_0

for var  in $DB_NAMES; do
    mysqldump -u $USER_NAME --password=${DB_PASS} $var > ${DBBACKUP_DIR_0}/${var}.sql
    gzip ${DBBACKUP_DIR_0}/${var}.sql
done

