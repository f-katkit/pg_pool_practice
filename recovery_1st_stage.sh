#!/bin/bash

MASTER_BASEDIR=$1
RECOVERY_HOST=$2
RECOVERY_BASEDIR=$3
WAL_DIR='/backup/postgresql/wal_archives/'

psql -c "SELECT pg_start_backup('pgpool-recovery')" postgres

echo "restore_command = 'cp ${WAL_DIR}%f %p'" > $MASTER_BASEDIR/recovery.conf

ssh -T $RECOVERY_HOST rm -rf $RECOVERY_BASEDIR.bk
ssh -T $RECOVERY_HOST mv -f $RECOVERY_BASEDIR{,.bk}


rsync -acz -e "ssh -o 'StrictHostKeyChecking no'" --exclude 'postgresql.conf' \
 $MASTER_BASEDIR/ $RECOVERY_HOST:$RECOVERY_BASEDIR/

ssh -o "StrictHostKeyChecking no" -T $RECOVERY_HOST rm -f $RECOVERY_BASEDIR/postmaster.pid
ssh -o "StrictHostKeyChecking no" -T $RECOVERY_HOST cp -f $RECOVERY_BASEDIR.bk/postgresql.conf $RECOVERY_BASEDIR/postgresql.conf

rm -f $MASTER_BASEDIR/recovery.conf

psql -c "SELECT pg_stop_backup()" postgres
